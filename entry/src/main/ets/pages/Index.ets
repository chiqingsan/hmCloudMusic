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

@Entry
@Component
struct HomeIndex {
  @StorageProp("bottomHeight") bottomHeight:number = 0
  @State
  currentName: string = 'recommend'
  @State
  opacityNum: number = 1


  aboutToAppear(): void {
    // 开始沉浸式状态栏
    windowManager.enableFullScreen(true)
    windowManager.settingStatusBar(true)
  }

  onPageShow(): void {
    // 开始沉浸式状态栏
    windowManager.enableFullScreen(true)
    windowManager.settingStatusBar(true)
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
      // .backgroundColor(item.name === this.currentName ?  : Color.Transparent)
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
    .animation({duration:500})
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
        .padding({bottom:this.bottomHeight})
        .onTabBarClick(index => {
            this.currentName = tabsData[index].name
        })
        // 背景播放
        if(this.currentName!=='mine'){
          PlayerNav()
            .translate({ y: -56-this.bottomHeight })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/play/Play'
              })
            })
        }

      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#121215')
    .opacity(this.opacityNum)
  }
  // 页面换效果,避免滑动切换效果
  pageTransition() {
    PageTransitionEnter({ duration: 200})
      .onEnter(() => {
        this.opacityNum = 1
      })
    PageTransitionExit({ duration: 200})
      .onExit(() => {
        this.opacityNum = 0
      })
  }
}


