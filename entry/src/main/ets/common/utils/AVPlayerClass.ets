import { media } from '@kit.MediaKit'
import { songItemType } from '../../models'
import { emitter } from '@kit.BasicServicesKit'
import { EmitEventType } from '../constants/EventConstants'
import { PlayStateType } from '../../models/playState'

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

  constructor() {
    this.init()
      .then((results) => {
        this.player = results
      })
  }

  // 更新歌曲信息至页面
  updateState(playState: PlayStateType) {
    emitter.emit({ eventId: EmitEventType.UPDATE_STATE }, {
      data: {
        playStateStr: playState
      }
    })
  }

  // 创建播放器的方法
  async init(): Promise<media.AVPlayer> {
    if (this.player) {
      return this.player
    }

    const AVPlayer = await media.createAVPlayer()

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
          AVPlayer.play();
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
          if (this.playMode === "repeat") {
            AVPlayer.play()
          } else {
            // 重置播放状态
            AVPlayer.reset()
          }
          break;
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
      this.time = time
      // 收集要通知的信息
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
      // // 通知页面
      this.updateState(playState)
    })

    //  监听设置播放时长
    AVPlayer.on('seekDone', () => {
      AVPlayer.play()
    })

    this.player = AVPlayer
    return this.player
  }

  // 单首歌播放
  async singlePlay(song: songItemType) {
    const AVPlayer = await this.init()
    // 每次调用播放的时候,如果播放器不处于暂停,都要重置掉之前的播放状态
    if (AVPlayer.state !== "paused") {
      await AVPlayer.reset()
    }
    // 判断是不是列表中的歌曲
    const isList = this.playList.some((item: songItemType) => item.id === song.id)
    // 如果是歌曲列表中的歌曲
    if (isList) {
      // 是不是正在播放的
      if (AVPlayer.url === song.url) {
        if (this.isPlay) {
          // 重新播放（切换当前播放索引的歌曲）
          this.changePlay()
        } else {
          // 恢复播放进度
          AVPlayer.seek(this.time)
          // AVPlayer.play()
        }
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
    // 添加到播放列表中，再进行播放
    // this.playList.unshift(song)
    // this.playIndex = 0
    // AVPlayer.url = song.url
  }

  // 切换歌曲
  async changePlay() {
    const AVPlayer = await this.init()
    // 重置播放器状态至初始化,异步方法
    await AVPlayer.reset()
    // 重置播放状态
    this.duration = 0
    this.time = 0
    AVPlayer.url = this.playList[this.playIndex].url
  }

  // 暂停歌曲
  async pausePlay() {
    const AVPlayer = await this.init()
    await AVPlayer.pause()
  }
}


export const HMAVPlayer = new AVPlayerClass()