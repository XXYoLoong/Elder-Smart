import router from '@ohos.router';

@Entry
@Component
struct CallPage {
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
        Text('紧急呼叫')
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
          // 紧急联系人卡片1
          Row() {
            // 左侧圆形呼叫图标
            Column() {
              Image($r('app.media.person'))
                .width(60)
                .height(60)
              Text('呼叫')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .margin({ top: 4 })
            }
            .backgroundColor('#F5F5F5')
            .borderRadius(30)
            .padding(10)
            .margin({ right: 16 })

            // 右侧联系人信息卡片
            Column() {
              Text('紧急联系人')
                .fontSize(14)
                .fontColor('#FFFFFF')
              Text('XXX')
                .fontSize(20)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
              Text('12345678910')
                .fontSize(18)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
            }
            .backgroundColor('#FF4D4D')
            .borderRadius(10)
            .padding(16)
            .layoutWeight(1)
          }
          .width('90%')
          .margin({ top: 30 })

          // 紧急联系人卡片2
          Row() {
            Column() {
              Image($r('app.media.person'))
                .width(60)
                .height(60)
              Text('呼叫')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .margin({ top: 4 })
            }
            .backgroundColor('#F5F5F5')
            .borderRadius(30)
            .padding(10)
            .margin({ right: 16 })

            Column() {
              Text('紧急联系人')
                .fontSize(14)
                .fontColor('#FFFFFF')
              Text('XXXX')
                .fontSize(20)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
              Text('12345678910')
                .fontSize(18)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
            }
            .backgroundColor('#4D7FFF')
            .borderRadius(10)
            .padding(16)
            .layoutWeight(1)
          }
          .width('90%')
          .margin({ top: 30 })

          // 紧急联系人卡片3
          Row() {
            Column() {
              Image($r('app.media.person'))
                .width(60)
                .height(60)
              Text('呼叫')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .margin({ top: 4 })
            }
            .backgroundColor('#F5F5F5')
            .borderRadius(30)
            .padding(10)
            .margin({ right: 16 })

            Column() {
              Text('紧急联系人')
                .fontSize(14)
                .fontColor('#FFFFFF')
              Text('XX')
                .fontSize(20)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
              Text('12345678910')
                .fontSize(18)
                .fontColor('#FFFFFF')
                .margin({ top: 4 })
            }
            .backgroundColor('#47C88A')
            .borderRadius(10)
            .padding(16)
            .layoutWeight(1)
          }
          .width('90%')
          .margin({ top: 30, bottom: 30 })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}