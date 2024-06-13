import { media } from '@kit.MediaKit'
import { songItemType } from '../../models'
import { emitter } from '@kit.BasicServicesKit'
import { EmitEventType } from '../constants/EventConstants'
import { PlayStateType, PlayStateTypeModel } from '../../models/playState'
import { MyPreferences } from './Preference'
import { PLAYSTATE } from '../constants/Persistence'
import { router } from '@kit.ArkUI'
import { songs } from '../../common/constants/MusicConstants';


export class AVPlayerClass {
  // 当前是否播放
  static isPlay: boolean = false
  // 创建的播放器应该存在我们的工具类上，这样才能被导出使用
  player: media.AVPlayer | null = null
  // 当前歌曲的时长(毫秒)
  duration: number = 0
  // 当前的播放时长（毫秒）
  time: number = 0
  // 当前是否播放
  isPlay: boolean = false
  // 当前播放模式
  playMode: 'auto' | 'repeat' | 'random' = 'auto'
  // 当前的播放列表
  playList: songItemType[] = []
  // 当前的播放序号
  playIndex: number = -1
  // 节流标识
  timer: number = -1

  // constructor() {
  //   this.init().then(player => {
  //     if (player) {
  //       this.player = player;
  //     } else {
  //       throw new Error('播放器初始化失败');
  //     }
  //   }).catch((error: Error) => {
  //     console.error('播放器初始化失败', error);
  //   });
  // }

  // 更新歌曲信息至页面
  updateState(playState: PlayStateType) {
    // 频繁发送通知和IO读写,可能会造成设备的耗电发热
    // emitter.emit({ eventId: EmitEventType.UPDATE_STATE }, {
    //   data: {
    //     playStateStr: playState
    //   }
    // })
    // 持久化当前播放的数据
    AppStorage.setOrCreate(PLAYSTATE, playState)
    MyPreferences.saveData(PLAYSTATE, playState)

  }

  // 创建播放器的方法
  async init() {
    if (this.player !== null) {
      return this.player
    }

    const AVPlayer = await media.createAVPlayer()
    // 读取首选项的播放状态
    const playState = MyPreferences.getData(PLAYSTATE, new PlayStateTypeModel())
    // 加载播放器状态(6种)
    // 有可能播放过强制退出,手动重置为未播放
    playState.isPlay = false
    this.time = playState.time
    this.duration = playState.duration
    this.playIndex = playState.playIndex
    this.playList = playState.playList
    this.playMode = playState.playMode
    // todo 开发方便, 把已有的列表加进去
    // 把歌曲列表加进去
    // this.playList = songs
    // playState.playList = songs
    // 更新播放状态
    this.updateState(playState)

    // 监听状态
    AVPlayer.on('stateChange', (state) => {
      switch (state) {
        case 'idle':
        // 当AVPlayer初始化后默认进入改状态,成功调用reset接口后也会进入该状态
        // player.fdSrc设置后,player会进入initialized状态,再次触发stateChange状态,进入该回调函数
          this.isPlay = false
          break;
        case 'initialized':
        // player设置player.fdSrc播放源后触发该状态上报
        // 将player设置为prepare(准备播放)状态,触发stateChange状态,再次进入回调函数
          AVPlayer.prepare();
          break;
        case 'prepared':
        // prepare调用成功后上报该状态机
        // 调用播放接口开始播放
          AVPlayer.seek(this.time);
          break;
        case 'playing':
          this.isPlay = true
        // play成功调用后触发该状态机上报
          break;
        case 'paused':
        // pause成功调用后触发该状态机上报
          this.isPlay = false
          break;
        case 'completed':
        // 播放结束后触发该状态机上报
          if (this.playMode === 'random' && this.playList.length > 1) {
            let index: number
            do {
              index = Math.floor(Math.random() * this.playList.length)
            } while (index === this.playIndex)
            this.playIndex = index
          } else if (this.playMode === 'auto') {
            this.playIndex++
            // 有可能加超过列表
            this.playIndex = (this.playIndex + this.playList.length) % this.playList.length
          }
        // 更新完索引切换歌曲即可
        // 如果是单曲循环,则直接播放自己本身
          this.singlePlay(this.playList[this.playIndex])
          break
        case 'stopped':
        // stop接口成功调用后触发该状态机上报
          AVPlayer.reset();
        // 调用reset接口初始化avplayer状态
          break;
        default:
          console.info('AVPlayer当前状态未知');
          break;
      }
    })
    //  监听歌曲时长
    AVPlayer.on('durationUpdate', (duration) => {
      // 每次切换歌曲都会触发这个函数，更新即可
      this.duration = duration
      console.log('duration:', this.duration)
      // 测试打印播放列表是否添加成功
      console.log('playIndex:', this.playIndex)
      console.log('playList:', JSON.stringify(this.playList))
    })
    //  监听播放时长
    AVPlayer.on('timeUpdate', (time) => {
      // 大坑,seek完了仍然会先走update为0，要恢复进度，防止将0的进度写入首选项进行播放
      if ((time !== 0 && this.time !== time) || AVPlayer.state === "paused") {
        this.time = time
        // 收集要通知的信息
        const playState: PlayStateType = {
          img: this.playList[this.playIndex].img,
          name: this.playList[this.playIndex].name,
          author: this.playList[this.playIndex].author,
          url: this.playList[this.playIndex].url,
          playIndex: this.playIndex,
          time: this.time,
          duration: this.duration,
          isPlay: this.isPlay,
          playMode: this.playMode,
          playList: this.playList
        }
        // 通知页面和首选项
        this.updateState(playState)
      }
    })

    //  监听设置播放时长
    AVPlayer.on('seekDone', async (time) => {
      // 及时更新当前播放的进度
      this.time = time
      console.log("seekDone:", time)
      // if (AVPlayer.state === "playing") {
      AVPlayer.play()
      // }
    })

    this.player = AVPlayer
    return this.player
  }

  // 单首歌播放
  async singlePlay(song: songItemType) {
    console.log(this.player?.state)
    // 每次调用播放的时候,如果播放器不处于暂停,都要重置掉之前的播放状态
    // if (this.player!.state !== "paused") {
    //   await this.player!.reset()
    // }
    // 判断是不是列表中的歌曲
    const isList = this.playList.some(item => item.id === song.id)
    // 如果是歌曲列表中的歌曲
    if (isList) {
      // 是不是正在播放的
      if (this.player!.url === song.url) {
        if (this.isPlay) {
          // 重新播放（切换当前播放索引的歌曲）
          this.changePlay()
        } else {
          // 恢复播放进度
          this.player!.seek(this.time)
          // this.player!.play()
        }
      } else if (!this.player!.url && this.time !== 0) {
        // 如果url为空,则继续播放
        this.player!.url = song.url
      } else {
        // 切换歌曲(更新播放索引切换歌曲)
        this.playIndex = this.playList.findIndex((item: songItemType) => item.id === song.id)
        this.changePlay()
      }
    } else {
      // 添加到播放列表中，再进行播放
      this.playList.unshift(song)
      this.playIndex = 0
      this.changePlay()
    }
  }

  // 跳转进度
  async jumpPlay(val: number) {

    if (this.isPlay) {
      this.player!.seek(val)
    } else {
      this.time = val
    }
  }

  // 切换歌曲
  async changePlay() {
    // const AVPlayer = await this.init()
    // 重置播放器状态至初始化,异步方法
    await this.player!.reset()
    // 重置播放状态
    this.duration = 0
    this.time = 0
    this.player!.url = this.playList[this.playIndex].url
  }

  // 暂停歌曲
  async pausePlay() {
    await this.player!.pause()
  }

  // 切换播放模式
  changeMode(mode: 'auto' | 'repeat' | 'random') {
    this.playMode = mode
    // 更新至页面（有可能暂停时切换）
    const playState: PlayStateType = {
      img: this.playList[this.playIndex]?.img,
      name: this.playList[this.playIndex]?.name,
      author: this.playList[this.playIndex]?.author,
      url: this.playList[this.playIndex]?.url,
      playIndex: this.playIndex,
      time: this.time,
      duration: this.duration,
      isPlay: this.isPlay,
      playMode: this.playMode,
      playList: this.playList
    }
    // 通知页面
    this.updateState(playState)
  }

  // 上一首
  previous() {
    if (this.playList.length === 0) {
      return
    }
    if (this.playMode === 'random' && this.playList.length > 1) {
      let index: number
      do {
        index = Math.floor(Math.random() * this.playList.length)
      } while (index === this.playIndex)
      this.playIndex = index
    } else {
      this.playIndex--
      // 有可能减到负数
      this.playIndex = (this.playIndex + this.playList.length) % this.playList.length
    }
    this.singlePlay(this.playList[this.playIndex])
  }

  // 下一首
  next() {
    if (this.playList.length === 0) {
      return
    }
    if (this.playMode === 'random' && this.playList.length > 1) {
      let index: number
      do {
        index = Math.floor(Math.random() * this.playList.length)
      } while (index === this.playIndex)
      this.playIndex = index
    } else {
      this.playIndex++
      // 有可能加超过列表
      this.playIndex = (this.playIndex + this.playList.length) % this.playList.length
    }
    this.singlePlay(this.playList[this.playIndex])
  }

  // 删除播放列表的歌曲
  async remove(item: songItemType) {
    // 移除正在播放的
    if (this.player?.url === item.url) {
      // 还有其他的歌
      if (this.playList.length > 1) {
        // 播下一首(播放会自动发布状态)
        const songIndex = this.playList.findIndex(v => v.id === item.id)
        this.playList.splice(songIndex, 1)
        // 有可能删除列表的最后一首
        this.playIndex = (this.playIndex + this.playList.length) % this.playList.length
        this.singlePlay(this.playList[this.playIndex])
      } else {
        // 就这一首
        // 重置播放器,删除数据，重置记录的状态，发布状态，返回首页
        this.player!.reset()
        this.playList = []
        this.isPlay = false
        this.duration = 0
        this.time = 0
        this.updateState(new PlayStateTypeModel())
        router.back()
      }
    } else {
      const songIndex = this.playList.findIndex(v => v.id === item.id)
      // 删除前面的
      if (this.playIndex > songIndex) {
        this.playIndex--
      }
      this.playList.splice(songIndex, 1)
      // 发布状态（可能是暂停删除的）
      this.updateState({
        img: this.playList[this.playIndex].img,
        name: this.playList[this.playIndex].name,
        author: this.playList[this.playIndex].author,
        url: this.playList[this.playIndex].url,
        playIndex: this.playIndex,
        time: this.time,
        duration: this.duration,
        isPlay: this.isPlay,
        playMode: this.playMode,
        playList: this.playList
      })
    }
  }
}


export const HMAVPlayer = new AVPlayerClass()