import router from '@ohos.router';

@Entry
@Component
struct DaohangPage {
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
        Text('导航')
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

      // 学校名称和图标
      Row() {
        Image($r('app.media.location'))
          .width(24)
          .height(24)
        Text('上海杉达学院（金海）')
          .fontSize(18)
          .fontColor('#1A1A1A')
          .margin({ left: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 位置信息卡片
      Column() {
        // 起点
        Row() {
          Image($r('app.media.start'))
            .width(24)
            .height(24)
          Text('我的位置')
            .fontSize(16)
            .fontColor('#1A1A1A')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(16)

        // 终点
        Row() {
          Image($r('app.media.end'))
            .width(24)
            .height(24)
          Text('输入目的地')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(16)

        // 导航按钮
        Button('导航')
          .width('90%')
          .height(45)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .margin({ top: 16, bottom: 16 })
          .borderRadius(22)
      }
      .width('95%')
      .margin({ top: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)

      // 地图区域
      Stack() {
        Image($r('app.media.map'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .layoutWeight(1)

      // 底部选项卡
      Row() {
        Button('步行')
          .width('33%')
          .height(45)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .backgroundColor('#FFFFFF')

        Button('打车')
          .width('33%')
          .height(45)
          .fontSize(16)
          .fontColor('#1A1A1A')
          .backgroundColor('#FFFFFF')

        Button('公交地铁')
          .width('33%')
          .height(45)
          .fontSize(16)
          .fontColor('#4080FF')
          .backgroundColor('#FFFFFF')
      }
      .width('100%')
      .padding(8)
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceEvenly)
      .position({ y: '100%' })
      .translate({ y: -53 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}