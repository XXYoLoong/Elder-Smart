import router from '@ohos.router';

@Entry
@Component
struct ShequPage {
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
        Text('社区')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
        Blank()
        Image($r('app.media.message'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)
      .margin({ top: -20 })

      // 使用Scroll包裹内容使其可滚动
      Scroll() {
        Column() {
          // 联系人区域
          Column() {
            Text('联系人')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 16, top: 16, bottom: 12 })

            Row() {
              // 联系人头像
              ForEach([1, 2, 3], () => {
                Column() {
                  Image($r('app.media.person'))
                    .width(40)
                    .height(40)
                    .margin({ right: 20 })
                }
              })
              
              // 添加按钮
              Image($r('app.media.add'))
                .width(40)
                .height(40)
            }
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ left: 16, right: 16 })
          }

          // 社区活动区域
          Column() {
            Text('社区活动')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 16, top: 24, bottom: 12 })

            // 活动图片
            Image($r('app.media.tu1'))
              .width('92%')
              .height(200)
              .borderRadius(8)
              .margin({ left: 16, right: 16 })
              .objectFit(ImageFit.Cover)
          }

          // 新闻娱乐区域
          Column() {
            Text('新闻娱乐')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 16, top: 24, bottom: 12 })

            // 新闻图片
            Image($r('app.media.tu2'))
              .width('92%')
              .height(200)
              .borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 20 })
              .objectFit(ImageFit.Cover)
          }
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