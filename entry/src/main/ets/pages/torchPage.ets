import router from '@ohos.router';

@Entry
@Component
struct TorchPage {
  build() {
    Column() {
      // 顶部返回栏
      Row() {
        Image($r('app.media.back1'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick((): void => {
            try { router.back() } catch {}
          })
        Text('点击返回')
          .fontSize(20)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      .onClick(() => {
        try {
          router.back();
        } catch (err) {
          console.error('跳转失败:', err)
        }
      })

      // 纯白高亮区域（不依赖任何权限）
      Column() {
        // 空内容即可，保证占满剩余空间
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
