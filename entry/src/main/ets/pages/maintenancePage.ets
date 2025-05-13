import router from '@ohos.router';

@Entry
@Component
struct MaintenancePage {
  @State private isAnimating: boolean = false;

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back1'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        Text('系统维护')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      // 主要内容区域
      Column() {
        // 维护图标
        Image($r('app.media.maintenance'))
          .width(120)
          .height(120)
          .margin({ top: 60 })
          .opacity(this.isAnimating ? 0.8 : 1)
          .animation({
            duration: 2000,
            tempo: 1.0,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })
          .onAppear(() => {
            this.isAnimating = true;
          })

        // 提示文本
        Text('系统维护中')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 24 })
          .fontColor('#333333')

        Text('为了给您提供更好的服务，系统正在进行升级维护')
          .fontSize(16)
          .margin({ top: 12 })
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .padding({ left: 32, right: 32 })

        // 二维码区域
        Column() {
          Text('请扫描下方二维码')
            .fontSize(16)
            .margin({ top: 48, bottom: 16 })
            .fontColor('#666666')

          Image($r('app.media.QRcode'))
            .width(200)
            .height(200)
            .borderRadius(16)
            .backgroundColor('#FFFFFF')
            .shadow({
              radius: 20,
              color: '#00000010',
              offsetX: 0,
              offsetY: 4
            })

          Text('下载专用软件使用完整功能')
            .fontSize(14)
            .margin({ top: 16 })
            .fontColor('#999999')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .backgroundColor('#F5F5F5')
        .borderRadius(24)
        .margin({ top: 32, left: 24, right: 24 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
  }
} 