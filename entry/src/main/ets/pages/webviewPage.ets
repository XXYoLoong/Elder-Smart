import { webview } from '@kit.ArkWeb';
import router from '@ohos.router';

@Entry
@Component
struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Row() {
        Image($r('app.media.back1'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        Text('HarmonyCare')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      Web({
        src: 'https://harmonycare.cn',
        controller: this.controller
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
  }
} 