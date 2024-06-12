import { media } from '@kit.MediaKit'

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

    this.player = await media.createAVPlayer()
    return this.player
  }
}


export const HMAVPlayer = new AVPlayerClass()