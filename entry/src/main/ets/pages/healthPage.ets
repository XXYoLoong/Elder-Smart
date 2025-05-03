import router from '@ohos.router';

@Entry
@Component
struct HealthPage {
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
        Text('健康管理')
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
          // 心率检测模块
          Column() {
            Row() {
              Image($r('app.media.1'))
                .width(24)
                .height(24)
              Text('心率检测')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })

            Column() {
              Row() {
                Column() {
                  Text('心率')
                    .fontSize(16)
                    .fontColor('#666666')
                  Row() {
                    Text('平均: 144')
                      .fontSize(16)
                    Text(' bpm')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  Row() {
                    Text('最大: 172')
                      .fontSize(16)
                    Text(' bpm')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(16)

              // 心率图表
              Image($r('app.media.heart'))
                .width('100%')
                .height(150)
                .objectFit(ImageFit.Cover)
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ top: 8 })
          }
          .width('92%')
          .backgroundColor('#FFE4E1')
          .borderRadius(16)
          .margin({ top: 16 })

          // 血氧饱和度模块
          Column() {
            Row() {
              Image($r('app.media.2'))
                .width(24)
                .height(24)
              Text('血氧饱和度低')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })

            // 合并后的血氧图表
            Image($r('app.media.heart2'))
              .width('100%')
              .height(100)
              .objectFit(ImageFit.Cover)
              .padding(16)
          }
          .width('92%')
          .backgroundColor('#FFE4E1')
          .borderRadius(16)
          .margin({ top: 16 })

          // 睡眠分析模块
          Column() {
            Row() {
              Image($r('app.media.3'))
                .width(24)
                .height(24)
              Text('睡眠分析')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })

            Column() {
              Text('日均睡眠时长')
                .fontSize(16)
                .fontColor('#666666')
              Row() {
                Text('6')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                Text('小时')
                  .fontSize(16)
                  .fontColor('#666666')
                Text('31')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 8 })
                Text('分钟')
                  .fontSize(16)
                  .fontColor('#666666')
              }
              .margin({ top: 8 })

              // 睡眠图表
              Image($r('app.media.sleep'))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
                .margin({ top: 16 })
            }
            .padding(16)
          }
          .width('92%')
          .backgroundColor('#FFE4E1')
          .borderRadius(16)
          .margin({ top: 16, bottom: 16 })
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
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}