import web_webview from '@ohos.web.webview';
import router from '@ohos.router';
@Entry
@Component
struct Page {
  @State message: string = ' ElderSmart+ 乐龄智伴'
  webviewController: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    Column() {
      Image($r('app.media.gongyi'))
        .width("69.62vp")
        .height("63.47vp")
        .offset({ x: "-118.39vp", y: "99.94vp" })

      Column() {
        Text(`${this.message}`)
          .width("300vp")
          .height("60vp")
          .offset({ x: "0vp", y: "-64.18vp" })
          .textAlign(TextAlign.Center)
          .fontSize("20fp")
          .fontWeight(FontWeight.Bold)

        Button("老人登录入口")
          .width("170vp")
          .height("65vp")
          .offset({ x: "0vp", y: "29.43vp" })
          .backgroundColor("#fff67638")
          .visibility(Visibility.Visible)
          .onClick(() => {
            router.pushUrl({ url: 'pages/Oldman'})
          })

        Button("监护人入口")
          .width("170vp")
          .height("65vp")
          .offset({ x: "0vp", y: "77.38vp" })
          .backgroundColor("#fff67638")
          .onClick(() => {
          router.pushUrl({ url: 'pages/Parents'})
        })
        Button("医护管理入口")
          .width("170vp")
          .height("65vp")
          .offset({ x: "0vp", y: "125.48vp" })
          .backgroundColor("#fff67638")
          .onClick(() => {
            router.pushUrl({ url: 'pages/view'})
          })

      }

      .width("100%")
      .height("100%")
      .offset({ x: "0vp", y: "-63.47vp" })
      .backgroundColor("#ff9fd0f6")
      .justifyContent(FlexAlign.Center)
    }
    .width("100%")
    .height("100%")
  }
}