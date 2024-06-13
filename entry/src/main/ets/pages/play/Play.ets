import { songs } from '../../common/constants/MusicConstants'
import { HMAVPlayer } from '../../common/utils/AVPlayerClass'
import { songItemType } from '../../models/music'
import { PlayStateType, PlayStateTypeModel } from '../../models/playState'
import { emitter } from '@kit.BasicServicesKit'
import { EmitEventType } from '../../common/constants/EventConstants'
import { MyPreferences } from '../../common/utils/Preference'
import { PLAYSTATE } from '../../common/constants/Persistence'

@Entry
@Component
struct Play {
  @StorageProp("topHeight") topHeight: number = 0
  @StorageProp("bottomHeight") bottomHeight: number = 0
  @State isPlay: boolean = false
  @State opacityNum: number = 1
  @State isShow: boolean = false
  @State randomNum: number = 0
  @State randomShakenX: number = 0
  @State randomShakenY: number = 0
  @State randomColor: string = 'rgb(0,0,0)'
  @State progressBarState: boolean = false
  @State playlist: songItemType[] = []
  // 进度条转跳转防抖
  jumpTimer: number = -1
  // 订阅事件
  @StorageProp(PLAYSTATE) @Watch('changeAnimate') playState: PlayStateType = new PlayStateTypeModel()

  aboutToAppear(): void {
    // this.playState = MyPreferences.getData(PLAYSTATE, new PlayStateTypeModel())
    // // AlertDialog.show({ message: JSON.stringify(this.playState, null, 2) })
    // // 只能手动指定为false
    // this.playState.isPlay = false
    // // this.playlist = this.playState.playList
    // emitter.on({ eventId: EmitEventType.UPDATE_STATE }, (data) => {
    //   if (data.data) {
    //     // this.playState = JSON.parse(data.data["PlayStateType"]) as PlayStateType
    //     this.playState = data.data?.playStateStr || {} as PlayStateType
    //     // this.progressBarNum = this.playState.time
    //   }
    // })
  }

  // 时长数字(ms)转字符串
  number2time(number: number) {
    const ms: number = number % 1000
    const second = (number - ms) / 1000
    const s: number = second % 60
    if (second > 60) {
      const m: number = (second - s) / 60 % 60
      return m.toString()
        .padStart(2, '0') + ':' + s.toString()
        .padStart(2, '0')
    }
    return '00:' + s.toString()
      .padStart(2, '0')
  }

  // 动画函数
  changeAnimate() {
    if (this.playState.isPlay) {
      this.randomNum = Math.random() * 50
      this.randomShakenX = 2 - Math.random() * 4
      this.randomShakenY = 2 - Math.random() * 4
      this.randomColor =
        `rgb(${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)})`
    } else {
      this.randomNum = 0
      this.randomShakenX = 0
      this.randomShakenY = 0
      this.randomColor =
        `rgb(${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)},${Math.floor(Math.random() * 255)})`
    }
  }

  // 播放和暂停
  async playMusic() {
    // 同步播放状态
    if (this.playState.isPlay) {
      await HMAVPlayer.pausePlay()
    } else {
      // if (this.playState.time) {
      //   console.log("Play_this.playState.time:", JSON.stringify(this.playState.time))
      //   const AVPlayer = await HMAVPlayer.init()
      //   console.log("Play_AVPlayer:", JSON.stringify(AVPlayer.state))
      //   AVPlayer.url = this.playState.url
      // } else {

      await HMAVPlayer.singlePlay(this.playState.playList[this.playState.playIndex])
      // }
    }
  }

  // 跳转播放
  async jumpPlayback(val: number, mode: SliderChangeMode) {
    // console.log(mode.toString())
    if (mode === SliderChangeMode.End || mode === SliderChangeMode.Click) {
      // console.log("val:", val)
      this.playState.time = val
      HMAVPlayer.jumpPlay(val)
      // const AVPlayer = await HMAVPlayer.init()
      // // await AVPlayer.pause()
      // AVPlayer.seek(val)
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

  // 点击列表播放
  async clickOnTheListToPlay(item: songItemType) {
    const index = this.playState.playList.findIndex(v => v.id === item.id)
    this.playState.playIndex = index
    await HMAVPlayer.singlePlay(this.playState.playList[index])
    this.isShow = false
  }

  @Builder
  deleteButton(item: songItemType, index: number) {
    Button('删除')
      .backgroundColor($r('app.color.primary_light'))
      .fontColor('#fff')
      .width(75)
      .height('100%')
      .type(ButtonType.Normal)
      .onClick(async () => {
        const AVPlayer = await HMAVPlayer.init()
        // 先更新UI,再去操作数据
        animateTo({ duration: 1000 }, () => {
          this.playlist.splice(index, 1)
        })
        HMAVPlayer.remove(index)

        // if (AVPlayer.url === item.url) {
        //   if (this.playState.playMode === 'random' && this.playState.playList.length > 1) {
        //     let index: number
        //     do {
        //       index = Math.floor(Math.random() * this.playState.playList.length)
        //     } while (index === this.playState.playIndex)
        //     this.playState.playIndex = index
        //   } else {
        //     this.playState.playIndex--
        //     // 有可能减到负数
        //     this.playState.playIndex =
        //       (this.playState.playIndex + this.playState.playList.length) % this.playState.playList.length
        //   }
        // }
      })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 内容
      Column() {
        // //   播放界面
        Column() {
          // 图片
          Stack({ alignContent: Alignment.Top }) {
            Row() {
              Row() {
                Image(this.playState.img || songs[0].img)
                  .width('70%')
                  .borderRadius(400)
              }
              .backgroundImage($r('app.media.ic_cd'))
              .backgroundImageSize(ImageSize.Cover)
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .borderRadius(400)
              .clip(true)
              .aspectRatio(1)
              .shadow({
                radius: this.randomNum,
                color: this.randomColor
              })
              .animation({
                duration: 1000,
              })
            }
            .margin({
              top: 50
            })
            .width('90%')
            .aspectRatio(1)
            .justifyContent(FlexAlign.Center)
            .padding(24)

            // 唱针
            Image($r('app.media.ic_stylus'))
              .width(200)
              .aspectRatio(1)
              .rotate({
                angle: -55,
                centerX: 100,
                centerY: 30
              })
              .animation({
                duration: 500
              })
          }

          // 歌曲信息
          Stack() {
            Column({ space: 8 }) {
              Text(this.playState.name || songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_dark'))
              Text(this.playState.author || songs[0].author)
                .fontSize(18)
                .fontColor($r('app.color.primary_dark'))
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .zIndex(1)
            .translate({
              x: this.randomShakenX,
              y: this.randomShakenY
            })

            Column({ space: 8 }) {
              Text(this.playState.name || songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_light'))
              Text(this.playState.author || songs[0].author)
                .fontSize(18)
                .fontColor($r('app.color.primary_light'))
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .zIndex(2)
            .translate({
              x: this.randomShakenX,
              y: this.randomShakenY
            })

            Column({ space: 8 }) {
              Text(this.playState.name || songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(this.playState.author || songs[0].author)
                .fontSize(18)
                .fontColor(Color.White)
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .zIndex(3)
          }
          .layoutWeight(1)

          // 操作
          Row() {
            Badge({ value: '99+', style: { badgeSize: 12, badgeColor: '#45CCCCCC' } }) {
              Image($r("app.media.ic_like"))
                .fillColor(Color.White)
                .width(24)
            }

            Badge({ value: '10W', style: { badgeSize: 12, badgeColor: '#45cccccc' } }) {
              Image($r("app.media.ic_comment_o"))
                .fillColor(Color.White)
                .width(24)
            }

            Badge({ value: 'hot', style: { badgeSize: 12, badgeColor: '#a8ff3131' } }) {
              Image($r("app.media.ic_bells_o"))
                .fillColor(Color.White)
                .width(26)
            }

            Badge({ value: 'vip', style: { badgeSize: 12, badgeColor: '#b7efd371' } }) {
              Image($r("app.media.ic_download_o"))
                .fillColor(Color.White)
                .width(24)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          // 播放
          Column() {
            // 进度条
            Row({ space: 4 }) {
              Text(this.number2time(this.playState.time || 0))
                .fontSize(12)
                .fontColor(Color.White)
              Slider({
                value: this.playState.time || 0,
                min: 0,
                max: this.playState.duration || 0
              })
                .layoutWeight(1)
                .blockColor(Color.White)
                .selectedColor(Color.White)
                .trackColor('#ccc5c5c5')
                .trackThickness(2)
                .onChange((val, mode) => {
                  this.jumpPlayback(val, mode)
                })
              Text(this.number2time(this.playState.duration || 0))
                .fontSize(12)
                .fontColor(Color.White)
            }
            .width('100%')
            .padding(24)

            // 切换
            Row() {
              // 播放模式切换
              if (this.playState.playMode === 'auto') {
                Image($r("app.media.ic_auto"))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    HMAVPlayer.changeMode('repeat')
                  })
              } else if (this.playState.playMode === 'repeat') {
                Image($r("app.media.ic_repeat"))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    HMAVPlayer.changeMode('random')
                  })
              } else if (this.playState.playMode === 'random') {
                Image($r("app.media.ic_random"))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    HMAVPlayer.changeMode('auto')
                  })
              } else {
                Image($r("app.media.ic_auto"))
                  .fillColor(Color.White)
                  .width(30)
                  .onClick(() => {
                    HMAVPlayer.changeMode('repeat')
                  })
              }

              // 上一首
              Image($r("app.media.ic_prev"))
                .fillColor(Color.White)
                .width(30)
                .onClick(() => {
                  this.previousOne()
                })

              // 播放按钮
              Image(this.playState.isPlay ? $r('app.media.ic_paused') : $r('app.media.ic_play'))
                .fillColor(Color.White)
                .width(50)
                .onClick(() => {
                  this.playMusic()
                })
              // 下一首
              Image($r('app.media.ic_next'))
                .fillColor(Color.White)
                .width(30)
                .onClick(() => {
                  this.nextSong()
                })
              // 播放列表
              Image($r('app.media.ic_song_list'))
                .fillColor(Color.White)
                .width(30)
                .bindSheet($$this.isShow,
                  this.aListOfSongs(), {
                    height: "50%",
                    showClose: false
                  })
                .onClick(() => {
                  this.isShow = true
                })
            }
            .width('100%')
            .padding({
              bottom: 24
            })
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width('100%')
          .padding({ bottom: this.bottomHeight })
        }
        .layoutWeight(1)
        .width('100%')
      }
      .padding({ top: this.topHeight })
      .linearGradient({
        angle: 180,
        colors: [["#DEDDDA", 0], ["#d1767470", .3], ["#f284837f", .5], ["#d5767470", .7], ["#CFCFCF", 1]]
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Transparent)
    .opacity(this.opacityNum)

  }

  @Builder
  aListOfSongs() {
    // 列表
    Column() {
      Column() {
        Row() {
          Row() {
            Image($r("app.media.ic_play"))
              .width(20)
              .fillColor('#ff5186')
          }
          .width(50)
          .aspectRatio(1)
          .justifyContent(FlexAlign.Center)

          Row({ space: 8 }) {
            Text(`播放列表 (${this.playlist.length})`)
              .fontColor(Color.White)
              .fontSize(14)
          }
          .layoutWeight(1)

          Image($r('app.media.ic_close'))
            .fillColor('#ffa49a9a')
            .width(24)
            .height(24)
            .margin({ right: 16 })
            .onClick(() => {
              this.isShow = false
            })
        }
        .width('100%')
        .backgroundColor('#ff353333')
        .padding(8)
        .border({
          width: { bottom: 1 },
          color: '#12ec5c87'
        })
        .borderRadius({
          topLeft: 4,
          topRight: 4
        })

        List() {
          ForEach(songs, (item: songItemType, index: number) => {
            ListItem() {
              Row() {
                Row() {
                  Text((index + 1).toString())
                    .fontColor('#ffa49a9a')
                }
                .width(50)
                .aspectRatio(1)
                .justifyContent(FlexAlign.Center)

                // 列表
                Row({ space: 10 }) {
                  Column() {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor(item.url === this.playState.url ? $r('app.color.primary_light') : '#ffa49a9a')
                    Text(item.author)
                      .fontSize(12)
                      .fontColor(item.url === this.playState.url ? $r('app.color.primary_light') : Color.Gray)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Center)
                }
                .layoutWeight(1)

                Image($r('app.media.ic_more'))
                  .width(18)
                  .height(18)
                  .margin({ right: 16 })
                  .fillColor(Color.Gray)
              }
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.clickOnTheListToPlay(item)
              })
            }
            .transition({
              translate: { x: "-150%" },
              opacity: 0
            })
            .swipeAction({
              end: this.deleteButton(item, index),

            })
            .border({
              width: { bottom: 1 },
              color: '#12ec5c87'
            })
          }, (item: songItemType, index) => item.id)
        }
        .layoutWeight(1)
        .backgroundColor('#ff353333')

      }
      .height(400)
    }
    .animation({
      duration: 300
    })
  }

  // 页面也换效果,避免滑动切换效果
  // pageTransition() {
  //   PageTransitionEnter({ duration: 200 })
  //     .onEnter(() => {
  //       this.opacityNum = 1
  //     })
  //   PageTransitionExit({ duration: 200 })
  //     .onExit(() => {
  //       this.opacityNum = 0
  //     })
  // }
}

