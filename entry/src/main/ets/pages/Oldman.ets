import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column() {
      // 顶部状态栏
      Row() {
        Image($r('app.media.WiFi'))
          .width(20)
          .height(20)
        Image($r('app.media.signal'))
          .width(20)
          .height(20)
          .margin({left: 5})
        Image($r('app.media.battery'))
          .width(25)
          .height(20)
          .margin({left: 5})
        Text('13%')
          .fontSize(14)
          .fontWeight(FontWeight.Normal)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
      }
      .width('100%')
      .padding(10)
      .justifyContent(FlexAlign.End)

      // 使用Scroll组件包裹可滚动内容
      Scroll() {
        Column() {
          // 时间日期和天气区域
          Column() {
            // 时间显示
            Text('18:30')
              .fontSize(80)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({top: 20})
              .fontStyle(FontStyle.Normal)
              .border({
                width: 2,
                color: $r('sys.color.ohos_id_color_text_primary'),
                style: BorderStyle.Solid
              })

            // 日期显示
            Text('2025.3.23')
              .fontSize(24)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({top: 10})

            // 天气信息
            Row() {
              Row() {
                Image($r('app.media.sun'))
                  .width(50)
                  .height(50)
              }

              Column() {
                Text('晴转多云')
                  .fontSize(24)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                Text('13-15°C')
                  .fontSize(20)
                  .fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 20 })
            }
            .margin({ top: 20, right: 30 })
            .justifyContent(FlexAlign.End)
            .width('100%')
            .height(80)
            .padding(10)
          }
          .width('100%')

          // 功能按钮区域
          Column() {
            // 乘车二维码
            Button() {
              Row() {
                Image($r('app.media.bus'))
                  .width(30)
                  .height(30)
                Text('乘车二维码')
                  .fontSize(20)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .margin({left: 15})
              }
              .width('100%')
              .padding({left: 20})
              .alignItems(VerticalAlign.Center)
            }
            .width('95%')
            .height(60)
            .margin({top: 10})
            .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
            .borderRadius(10)
            .onClick(() => {
              try {
                router.pushUrl({ url: 'pages/Buspage' })
              } catch (err) {
                console.error('跳转失败:', err);
              }
            })

            // 紧急呼叫
            Button() {
              Row() {
                Image($r('app.media.call'))
                  .width(30)
                  .height(30)
                Text('紧急呼叫')
                  .fontSize(20)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .margin({left: 15})
              }
              .width('100%')
              .padding({left: 20})
              .alignItems(VerticalAlign.Center)
            }
            .width('95%')
            .height(60)
            .margin({top: 10})
            .backgroundColor($r('sys.color.ohos_id_color_warning'))
            .borderRadius(10)
            .onClick(() => {
              try {
                router.pushUrl({ url: 'pages/callPage' })
              } catch (err) {
                console.error('跳转失败:', err);
              }
            })

            // 导航和相机行
            Row() {
              // 导航
              Button() {
                Column() {
                  Image($r('app.media.daohang'))
                    .width(30)
                    .height(30)
                  Text('导航')
                    .fontSize(20)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .margin({top: 5})
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('46%')
              .height(80)
              .backgroundColor($r('sys.color.ohos_id_color_connected'))
              .borderRadius(10)
              .onClick(() => {
                try {
                  router.pushUrl({ url: 'pages/daohangPage' })
                } catch (err) {
                  console.error('跳转失败:', err);
                }
              })

              // 相机
              Button() {
                Column() {
                  Image($r('app.media.camera'))
                    .width(30)
                    .height(30)
                  Text('相机')
                    .fontSize(20)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .margin({top: 5})
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('46%')
              .height(80)
              .backgroundColor($r('sys.color.ohos_id_color_secondary'))
              .borderRadius(10)
            }
            .width('95%')
            .margin({top: 10})
            .justifyContent(FlexAlign.SpaceBetween)

            // 社区和日程行
            Row() {
              // 社区
              Button() {
                Column() {
                  Image($r('app.media.community'))
                    .width(30)
                    .height(30)
                  Text('社区')
                    .fontSize(20)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .margin({top: 5})
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('46%')
              .height(80)
              .backgroundColor($r('sys.color.ohos_id_color_tertiary'))
              .borderRadius(10)
              .onClick(() => {
                try {
                  router.pushUrl({ url: 'pages/shequPage' })
                } catch (err) {
                  console.error('跳转失败:', err);
                }
              })

              // 日程
              Button() {
                Column() {
                  Image($r('app.media.calendar'))
                    .width(30)
                    .height(30)
                  Text('日程')
                    .fontSize(20)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .margin({top: 5})
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('46%')
              .height(80)
              .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
              .borderRadius(10)
              .onClick(() => {
                try {
                  router.pushUrl({ url: 'pages/richengPage' })
                } catch (err) {
                  console.error('跳转失败:', err);
                }
              })
            }
            .width('95%')
            .margin({top: 10})
            .justifyContent(FlexAlign.SpaceBetween)

            // 健康管理
            Button() {
              Row() {
                Image($r('app.media.health'))
                  .width(30)
                  .height(30)
                Text('健康管理')
                  .fontSize(20)
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .margin({left: 15})
              }
              .width('100%')
              .padding({left: 20})
              .alignItems(VerticalAlign.Center)
            }
            .width('95%')
            .height(60)
            .margin({top: 10})
            .backgroundColor($r('sys.color.ohos_id_color_hover'))
            .borderRadius(10)
            .onClick(() => {
              try {
                router.pushUrl({ url: 'pages/healthPage' })
              } catch (err) {
                console.error('跳转失败:', err);
              }
            })
          }
          .width('100%')
          .margin({top: 20})
          .padding({bottom: 80}) // 添加底部内边距，避免最后一个按钮被底部导航栏遮挡
        }
      }
      .scrollBar(BarState.Off) // 隐藏滚动条
      .edgeEffect(EdgeEffect.Spring) // 设置滚动到边缘时的效果
      .width('100%')
      .height('85%') // 设置滚动区域的高度，留出底部导航栏的空间

      // 底部导航栏
      Row() {
        Column() {
          Image($r('app.media.home1'))
            .width(25)
            .height(25)
          Text('首页')
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .margin({top: 5})
        }

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
          Image($r('app.media.user1'))
            .width(25)
            .height(25)
          Text('我的')
            .fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary'))
            .margin({top: 5})
        }
        .onClick(() => {
          try {
            router.replaceUrl({
              url: 'pages/minePage',
              params: {
                from: 'index'
              }
            })
          } catch (err) {
            console.error('跳转失败:', err);
          }
        })
      }
      .width('100%')
      .height(70)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .position({y: '100%'})
      .translate({y: -70})
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}