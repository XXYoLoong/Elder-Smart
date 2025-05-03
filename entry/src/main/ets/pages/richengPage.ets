import router from '@ohos.router';

@Entry
@Component
struct RichengPage {
  @State message: string = 'Hello World';

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back1'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            try {
              router.back();
            } catch (err) {
              console.error('返回失败:', err);
            }
          })
        Text('日程')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)
      .margin({ top: -20 })

      // 使用Scroll包裹内容使其可滚动
      Scroll() {
        Column() {
          // 日程列表
          // 量血压
          Row() {
            Checkbox()
              .width(24)
              .height(24)
              .margin({ right: 16 })
            Column() {
              Text('量血压')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Text('每天 7:00')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFE4E1')
          .borderRadius(8)
          .margin({ top: 30 })

          // 饭后吃药
          Row() {
            Checkbox()
              .width(24)
              .height(24)
              .margin({ right: 16 })
            Column() {
              Text('饭后吃药')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Text('每天 12:30')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFE4E1')
          .borderRadius(8)
          .margin({ top: 30 })

          // 广场舞表演
          Row() {
            Checkbox()
              .width(24)
              .height(24)
              .margin({ right: 16 })
            Column() {
              Text('广场舞表演')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Text('6.23 17:00')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFE4E1')
          .borderRadius(8)
          .margin({ top: 30 })

          // 医院回诊
          Row() {
            Checkbox()
              .width(24)
              .height(24)
              .margin({ right: 16 })
            Column() {
              Text('医院回诊')
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Text('3.31 10:00')
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFE4E1')
          .borderRadius(8)
          .margin({ top: 30, bottom: 30 })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .layoutWeight(1)

      // 底部按钮
      Row() {
        // 增加日程按钮
        Column() {
          Image($r('app.media.add'))
            .width(30)
            .height(30)
          Text('增加日程')
            .fontSize(16)
            .fontColor('#1A1A1A')
            .margin({ top: 4 })
        }
        .onClick(() => {
          // 处理增加日程的逻辑
        })

        // 删减日程按钮
        Column() {
          Image($r('app.media.delete'))
            .width(30)
            .height(30)
          Text('删减日程')
            .fontSize(16)
            .fontColor('#1A1A1A')
            .margin({ top: 4 })
        }
        .onClick(() => {
          // 处理删减日程的逻辑
        })
      }
      .width('100%')
      .padding({ left: 60, right: 60, bottom: 20 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}