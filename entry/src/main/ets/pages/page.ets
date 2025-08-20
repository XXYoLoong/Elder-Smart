import web_webview from '@ohos.web.webview';
import router from '@ohos.router';

@Entry
@Component
struct Page {
  @State message: string = 'ElderSmart+ 乐龄智伴'
  webviewController: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    Column() {
      // LOGO或顶部图片
      Image($r('app.media.gongyi'))
        .width(80)
        .height(80)
        .margin({ bottom: 24 })

      // 标题
      Text(this.message)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222b45')
        .margin({ bottom: 40 })

      // 按钮组
      Button('软件入口')
        .width(220)
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#4e8cff')
        .fontColor('#ffffff')
        .borderRadius(24)
        .shadow({ radius: 8, color: '#4e8cff33', offsetY: 2 })
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/Oldman'})
        })

      // Button('监护人入口')
      //   .width(220)
      //   .height(48)
      //   .fontSize(18)
      //   .fontWeight(FontWeight.Medium)
      //   .backgroundColor('#34c759')
      //   .fontColor('#ffffff')
      //   .borderRadius(24)
      //   .shadow({ radius: 8, color: '#34c75933', offsetY: 2 })
      //   .margin({ bottom: 20 })
      //   .onClick(() => {
      //     router.pushUrl({ url: 'pages/Parents'})
      //   })

      Button('数据分析系统')
        .width(220)
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#ff9500')
        .fontColor('#ffffff')
        .borderRadius(24)
        .shadow({ radius: 8, color: '#ff950033', offsetY: 2 })
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/webviewPage'})
        })

      // Button('多模态监测')
      //   .width(220)
      //   .height(48)
      //   .fontSize(18)
      //   .fontWeight(FontWeight.Medium)
      //   .backgroundColor('#ff3b30')
      //   .fontColor('#ffffff')
      //   .borderRadius(24)
      //   .shadow({ radius: 8, color: '#ff3b3033', offsetY: 2 })
      //   .onClick(() => {
      //     router.pushUrl({ url: 'pages/maintenancePage'});
      //   })
    }
    .align(Alignment.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [
        [0xe0ecff, 0.0], // 渐变起点色
        [0xf6fafd, 1.0]  // 渐变终点色
      ]
    })
  }
}