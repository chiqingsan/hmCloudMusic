import router from '@ohos.router'
import { window } from '@kit.ArkUI'
import { windowManager } from '../../common/utils/windowManager'

@Entry
@Component
struct Advertisement {
  @State time: number = 5
  timer: number = -1
  aboutToAppear() {
    // 必须重置才能改动画的内容
    this.timer = setInterval(() => {
      if (this.time <= 0) {
        clearInterval(this.timer)
        router.replaceUrl({
          url: 'pages/Index'
        })
        return
      }
      this.time -= 1
    }, 1000)
  }

  // 关闭广告
  closeWin() {
    window.findWindow("ad_window").destroyWindow()
  }

  aboutToDisappear(): void {
    // 开始沉浸式状态栏
    windowManager.enableFullScreen(true)
    clearInterval(this.timer)
  }


  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
        Row() {
        }
        .width('100%')
        .height('100%')
        .backgroundImage($r('app.media.ad'))
        .backgroundImageSize({
          width: '100%',
          height: '100%'
        })

      Button(`${this.time}秒后跳过`)
        .padding({ left: 10, right: 10 })
        .margin({ right: 20, top: 20 })
        .height(30)
        .fontSize(14)
        .borderRadius(15)
        .backgroundColor($r("app.color.background_page"))
        .onClick(() => {
          this.closeWin()
        })
        .offset({
          y: 30
        })
    }
    .width('100%')
    .height('100%')
  }
}