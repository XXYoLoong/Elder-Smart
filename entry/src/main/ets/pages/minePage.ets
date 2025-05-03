import router from '@ohos.router';

@Entry
@Component
struct MinePage {
  @State message: string = 'Hello World';

  build() {
    Column() {
      // 顶部设置按钮
      Row() {
        Blank()
        Image($r('app.media.settings'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .margin({ top: -20 })

      // 使用Scroll包裹内容使其可滚动
      Scroll() {
        Column() {
          // 用户信息区域
          Column() {
            Image($r('app.media.wo'))
              .width(100)
              .height(100)
              .borderRadius(50)
              .margin({ top: 20 })

            Text('李奶奶')
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .margin({ top: 16 })

            // IP和编辑资料按钮
            Row() {
              Button('IP：上海')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .backgroundColor('#FFE4E1')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })

              Button('编辑资料')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .backgroundColor('#FFE4E1')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 16 })
            }
            .margin({ top: 16 })
          }
          .width('100%')
          .padding({ bottom: 20 })

          // 功能列表
          Column() {
            // 今日步数
            Row() {
              Row() {
                Image($r('app.media.steps'))
                  .width(24)
                  .height(24)
                Text('今日步数')
                  .fontSize(16)
                  .fontColor('#1A1A1A')
                  .margin({ left: 12 })
              }
              Image($r('app.media.right'))
                .width(20)
                .height(20)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            // 支付
            Row() {
              Row() {
                Image($r('app.media.wallet'))
                  .width(24)
                  .height(24)
                Text('支付')
                  .fontSize(16)
                  .fontColor('#1A1A1A')
                  .margin({ left: 12 })
              }
              Image($r('app.media.right'))
                .width(20)
                .height(20)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            // 意见反馈
            Row() {
              Row() {
                Image($r('app.media.feedback'))
                  .width(24)
                  .height(24)
                Text('意见反馈')
                  .fontSize(16)
                  .fontColor('#1A1A1A')
                  .margin({ left: 12 })
              }
              Image($r('app.media.right'))
                .width(20)
                .height(20)
            }
            .width('100%')
            .height(60)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF')
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          .margin({ top: 20 })

          // 退出登录按钮
          Button('退出登录')
            .width('90%')
            .height(50)
            .fontSize(18)
            .fontColor('#FFFFFF')
            .backgroundColor($r('sys.color.ohos_id_color_warning'))
            .borderRadius(25)
            .margin({ top: 40, bottom: 20 })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .layoutWeight(1)

      // 底部导航栏
      Row() {
        Column() {
          Image($r('app.media.home2'))
            .width(25)
            .height(25)
          Text('首页')
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .margin({ top: 4 })
        }
        .onClick(() => {
          try {
            router.replaceUrl({
              url: 'pages/Oldman',
              params: {
                from: 'mine'
              }
            })
          } catch (err) {
            console.error('跳转失败:', err);
          }
        })

        Button() {
          Image($r('app.media.mic'))
            .width(30)
            .height(30)
        }
        .width(60)
        .height(60)
        .backgroundColor($r('sys.color.ohos_id_color_activated'))
        .borderRadius(30)

        Column() {
          Image($r('app.media.user2'))
            .width(25)
            .height(25)
          Text('我的')
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .margin({ top: 4 })
        }
      }
      .width('100%')
      .height(70)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}