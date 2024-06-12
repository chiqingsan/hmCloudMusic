import { songs } from '../constants/MusicConstants'
import { HMAVPlayer } from '../utils/AVPlayerClass'

@Component
struct PlayerNav {
  activeIndex: number = 0

  build() {
    Row() {
      Row({ space: 10 }) {
        Image(songs[0].img)
          .width(35)
          .aspectRatio(1)
          .borderRadius(5)
        Column() {
          Text(songs[0].name)
            .fontColor('#fff')
          Text(songs[0].author)
            .fontSize(12)
            .fontColor('#ccc')
        }.alignItems(HorizontalAlign.Start)
      }.height('100%')
      .alignItems(VerticalAlign.Center)

      Row({ space: 16 }) {
        Image($r("app.media.ic_prev"))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .enabled(this.activeIndex >= 0)
          .onClick(() => {
            HMAVPlayer.singlePlay(songs[--this.activeIndex])
          })
        Image($r('app.media.ic_play'))
          .fillColor('#4cafc6')
          .width(20)
          .onClick(() => {
            HMAVPlayer.singlePlay(songs[this.activeIndex])
          })

        Image($r('app.media.ic_next'))
          .width(20)
          .aspectRatio(1)
          .fillColor('#4cafc6')
          .enabled(this.activeIndex < songs.length)
          .onClick(() => {

            HMAVPlayer.singlePlay(songs[++this.activeIndex])
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