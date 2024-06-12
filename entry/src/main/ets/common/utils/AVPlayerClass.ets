import { media } from '@kit.MediaKit'
import { songItemType } from '../../models'

export class AVPlayerClass {
  // 创建的播放器应该存在我们的工具类上，这样才能被导出使用
  player: media.AVPlayer | null = null

  constructor() {
    this.init()
      .then((results) => {
        this.player = results
      })
  }

  // 创建播放器的方法
  async init() {
    if (this.player) {
      return this.player
    }

    const AVPlayer = await media.createAVPlayer()

    // 监听状态
    AVPlayer.on('stateChange', (state) => {
      switch (state) {
      // 初始化
        case 'initialized':
          AVPlayer.prepare()
          break
      // 准备
        case 'prepared':
          AVPlayer.play()
          break
        default:
          console.log("当前为未知状态")
      }
    })

    this.player = AVPlayer
    return this.player
  }

  // 单首歌播放
  async singlePlay(song: songItemType) {
    const AVPlayer = await this.init()
    AVPlayer.url = song.url
  }
}


export const HMAVPlayer = new AVPlayerClass()