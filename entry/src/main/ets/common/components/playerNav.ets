import { PlayStateType, PlayStateTypeModel } from '../../models/playState'
import { songs } from '../constants/MusicConstants'
import { PLAYSTATE } from '../constants/Persistence'
import { HMAVPlayer } from '../utils/AVPlayerClass'

@Component
struct PlayerNav {
  @StorageProp(PLAYSTATE) playState: PlayStateType = new PlayStateTypeModel()

  async playMusic() {
    try { // 同步播放状态
      if (this.playState?.isPlay) {
        await HMAVPlayer.pausePlay()
      } else {
        await HMAVPlayer.singlePlay(this.playState.playList[this.playState.playIndex])
      }
    } catch (e) {
      console.log("playerNav_e:", JSON.stringify(e))
    }
  }

  // 上一首
  previousOne() {
    HMAVPlayer.previous()
  }

  // 下一首
  nextSong() {
    HMAVPlayer.next()
  }

  build() {
    Row() {
      Row({ space: 10 }) {
        Image(this.playState.img)
          .width(35)
          .aspectRatio(1)
          .borderRadius(5)
        Column() {
          Text(this.playState.name)
            .fontColor('#fff')
          Text(this.playState.author)
            .fontSize(12)
            .fontColor('#ccc')
        }.alignItems(HorizontalAlign.Start)
      }.height('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 16 }) {

        Image($r("app.media.ic_prev"))
          .width(20)
          .aspectRatio(1)// .fillColor('#4cafc6')
            //FF4A7883 按压状态
          .fillColor('#4cafc6')
          .onClick(() => {
            this.previousOne()
          })


        Image(this.playState.isPlay ? $r("app.media.ic_paused") : $r("app.media.ic_play"))
          .fillColor('#4cafc6')
          .width(20)
          .onClick(() => {
            this.playMusic()
          })

        Image($r('app.media.ic_next'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .onClick(() => {
            this.nextSong()
          })
      }.height('100%')
    }
    .width('100%')
    .height(60)
    .backgroundColor('#ff1c1c21')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 20, right: 20 })
  }
}


export default PlayerNav