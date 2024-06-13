import { TabClass } from '../models'
import Find from './find/Find'
import Mine from './my/Mine'
import Moment from './dynamic/Moment'
import Recommend from './recommend/Recommend'
import SongList from './music/SongList'
import router from '@ohos.router'
import PlayerNav from '../common/components/playerNav'
import { tabsData } from '../common/constants'
import { windowManager } from '../common/utils/windowManager'
import { emitter } from '@kit.BasicServicesKit'
import { EmitEventType } from '../common/constants/EventConstants'
import { PlayStateType } from '../models/playState'
import { JSON } from '@kit.ArkTS'
import { MyPreferences } from '../common/utils/Preference'
import { PLAYSTATE } from '../common/constants/Persistence'

@Entry
@Component
struct HomeIndex {
  @StorageProp("bottomHeight") bottomHeight: number = 0
  @State
  currentName: string = 'recommend'
  @State
  opacityNum: number = 1
  @Provide playState: PlayStateType = {} as PlayStateType

  aboutToAppear(): void {
    // 开始沉浸式状态栏
    windowManager.enableFullScreen(true)
    windowManager.settingStatusBar(true)
    // 获取持久化信息
    this.playState = MyPreferences.getData(PLAYSTATE, {} as PlayStateType)
    // 只能手动指定为false
    this.playState.isPlay = false
    emitter.on({ eventId: EmitEventType.UPDATE_STATE }, (data) => {
      if (data.data) {
        // this.playState = JSON.parse(data.data["PlayStateType"]) as PlayStateType
        this.playState = data.data?.playStateStr || {} as PlayStateType
        // console.log(JSON.stringify(data.data));
      }
    })
  }

  onPageShow(): void {

  }

  // tabBar组件
  @Builder
  getTabBar(item: TabClass) {
    Column() {
      Row() {
        Image(item.icon)
          .fillColor(item.name === this.currentName ? $r('app.color.primary_light') : $r('app.color.primary_dark'))
          .width(item.name === this.currentName ? 22 : 18)
          .aspectRatio(1)
      }
      .width(22)
      .aspectRatio(1)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)

      Text(item.title)
        .fontSize(12)
        .fontWeight(400)
        .margin({ top: 5 })
        .fontColor(item.name === this.currentName ? $r('app.color.primary_light') : $r('app.color.primary_dark'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .animation({ duration: 1000 })
  }

  build() {
    Stack() {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ barPosition: BarPosition.End }) {
          ForEach(tabsData, (item: TabClass) => {
            TabContent() {
              if (item.name === 'recommend') {
                Recommend()
              } else if (item.name === 'find') {
                Find()
              } else if (item.name === 'moment') {
                Moment()
              } else if (item.name === 'mine') {
                Mine()
              } else {
                SongList()
              }
            }
            .tabBar(this.getTabBar(item))
            .backgroundColor('#121215')
          })
        }
        .scrollable(false)
        .backgroundColor("#2D2A2A")
        .padding({ bottom: this.bottomHeight })
        .onTabBarClick(index => {
          this.currentName = tabsData[index].name
        })

        // 背景播放
        if (this.currentName !== 'mine') {
          PlayerNav()
            .translate({ y: -56 - this.bottomHeight })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/play/Play'
              })
            })
          // .visibility(this.playState.playList?.length && this.currentName !== 'mine' ? Visibility.Visible :
          // Visibility.Hidden)

        }

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121215')
    .opacity(this.opacityNum)
  }

  // 页面换效果,避免滑动切换效果
  // pageTransition() {
  //   PageTransitionEnter({ duration: 200})
  //     .onEnter(() => {
  //       this.opacityNum = 1
  //     })
  //   PageTransitionExit({ duration: 200})
  //     .onExit(() => {
  //       this.opacityNum = 0
  //     })
  // }
}


