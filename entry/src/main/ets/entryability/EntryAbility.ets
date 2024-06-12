import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import { AbilityConstant, Want } from '@kit.AbilityKit';
import { HMAVPlayer } from "../common/utils/AVPlayerClass"
import { songs } from '../common/constants/MusicConstants';
import { MyPreferences } from '../common/utils/Preference';
import { PLAYSTATE } from '../common/constants/Persistence';
import { PlayStateType } from '../models/playState';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

   onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');

  }

  async onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 启动子窗口来展示开屏广告
    // todo 开发的时候,不展示开屏
    // const win = await windowStage.createSubWindow("ad_window")
    // await win.showWindow()
    // win.setUIContent("pages/start/Advertisement")

    // 初始化AVPlayer播放器
    HMAVPlayer.init()
    // 把歌曲列表加进去
    HMAVPlayer.playList = songs
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
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
