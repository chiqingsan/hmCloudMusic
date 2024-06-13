import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { AbilityConstant, errorManager, Want } from '@kit.AbilityKit';
import { HMAVPlayer } from "../common/utils/AVPlayerClass"
import { FaultLogger } from '@kit.PerformanceAnalysisKit';

let errorManagerId: number

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    //注册错误观察器,来捕获未知的错误
    errorManagerId = errorManager.on("error", {
      async onUnhandledException() {
        const errorInfoList = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
        const errorInfo = errorInfoList[0]
        // AlertDialog.show({
        //   message: JSON.stringify(errorInfo, null, 2)
        // })
        console.log("EntryAbility_errorInfo:", JSON.stringify(errorInfo))
      }
    })
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');

    // 释放错误观测器
    errorManager.off("error", errorManagerId)
    // 释放播放器实例
    HMAVPlayer.release()
  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 启动子窗口来展示开屏广告
    const win = await windowStage.createSubWindow("ad_window")
    await win.showWindow()
    win.setUIContent("pages/start/Advertisement")


    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      // 初始化AVPlayer播放器
      HMAVPlayer.init()
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');


  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');

  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
