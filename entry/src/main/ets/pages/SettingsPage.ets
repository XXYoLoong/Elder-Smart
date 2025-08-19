import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Settings, loadSettings, saveSettings } from '../common/PrefStore'

@Entry
@Component
struct SettingsPage {
  @State private bigText: boolean = false
  @State private soundOn: boolean = true

  aboutToAppear(): void {
    const s: Settings = loadSettings()
    this.bigText = s.bigText
    this.soundOn = s.soundOn
  }

  private persist(): void {
    const s: Settings = { bigText: this.bigText, soundOn: this.soundOn }
    saveSettings(s)
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Image($r('app.media.back1')).width(24).height(24).margin({ left: 16 })
          .onClick(() => router.back())
        Text('设置').fontSize(20).fontWeight(FontWeight.Medium).margin({ left: 12 })
        Blank()
      }
      .width('100%').height(56).alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF')
      .margin({ top: -20 })

      // 内容
      Column() {
        // 大号字体
        Row() {
          Text('大号字体').fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.bigText })
            .onChange((on: boolean): void => { this.bigText = on; this.persist() })
        }
        .width('92%').height(48).alignItems(VerticalAlign.Center)

        // 提示音
        Row() {
          Text('提示音').fontSize(16)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: this.soundOn })
            .onChange((on: boolean): void => { this.soundOn = on; this.persist() })
        }
        .width('92%').height(48).alignItems(VerticalAlign.Center).margin({ top: 8 })

        // 保存按钮（可选，已在切换时自动保存）
        Button('保存')
          .width('92%').height(44).margin({ top: 16 })
          .onClick(() => { this.persist(); promptAction.showToast({ message: '已保存' }) })
      }
      .width('100%').alignItems(HorizontalAlign.Center).margin({ top: 12 })

      Blank().layoutWeight(1)

      // 返回
      Button('返回')
        .width('92%').height(44).margin({ bottom: 16 })
        .onClick(() => router.back())
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
