import { songs } from '../../common/constants/MusicConstants'
import { songItemType } from '../../models/music'

@Entry
@Component
struct Play {
  @StorageProp("topHeight") topHeight: number = 0
  @StorageProp("bottomHeight") bottomHeight: number = 0
  @State opacityNum: number = 1
  @State panelHeight: string = '0%'
  @State isShow: boolean = false

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

  @Builder
  deleteButton(index: number) {
    Button('删除')
      .backgroundColor($r('app.color.primary_light'))
      .fontColor('#fff')
      .width(80)
      .height('100%')
      .type(ButtonType.Normal)
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 播放
      // 变色背景
      // Image(songs[0].img)
      //   .width('100%')
      //   .height('100%')
      //   .blur(1000)
      // 内容
      Column() {
        // //   播放界面
        Column() {
          // 图片
          Stack({ alignContent: Alignment.Top }) {
            Row() {
              Row() {
                Image(songs[0].img)
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
              Text(songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_dark'))
              Text(songs[0].author)
                .fontSize(18)
                .fontColor($r('app.color.primary_dark'))
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .zIndex(1)

            Column({ space: 8 }) {
              Text(songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary_light'))
              Text(songs[0].author)
                .fontSize(18)
                .fontColor($r('app.color.primary_light'))
            }
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
            .zIndex(2)

            Column({ space: 8 }) {
              Text(songs[0].name)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              Text(songs[0].author)
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
              Text('00:00')
                .fontSize(12)
                .fontColor(Color.White)
              Slider({
                value: 0,
                min: 0,
                max: 0
              })
                .layoutWeight(1)
                .blockColor(Color.White)
                .selectedColor(Color.White)
                .trackColor('#ccc5c5c5')
                .trackThickness(2)
              Text('00:00')
                .fontSize(12)
                .fontColor(Color.White)
            }
            .width('100%')
            .padding(24)

            // 切换
            Row() {
              Image($r('app.media.ic_auto'))
                .fillColor(Color.White)
                .width(30)

              Image($r("app.media.ic_prev"))
                .fillColor(Color.White)
                .width(30)

              // 播放按钮
              Image($r('app.media.ic_play'))
                .fillColor(Color.White)
                .width(50)
              // 下一首
              Image($r('app.media.ic_next'))
                .fillColor(Color.White)
                .width(30)
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
                  // this.panelHeight = '100%'
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

    // .padding({top:this.topHeight,bottom:this.bottomHeight})

  }

  @Builder
  aListOfSongs() {
    // 列表
    Column() {
      Column()
        .width('100%')
        .layoutWeight(1)
        .onClick(() => {
          this.isShow = false
        })

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
            Text(`播放列表 (${songs.length})`)
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
                      .fontColor(index === 0 ? $r('app.color.primary_light') : '#ffa49a9a')
                    Text(item.author)
                      .fontSize(12)
                      .fontColor(index === 0 ? $r('app.color.primary_light') : Color.Gray)
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
            }
            .swipeAction({
              end: this.deleteButton(index)
            })
            .border({
              width: { bottom: 1 },
              color: '#12ec5c87'
            })
          })
        }
        .layoutWeight(1)
        .backgroundColor('#ff353333')

      }
      .height(400)
    }
    .height(this.panelHeight)
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

