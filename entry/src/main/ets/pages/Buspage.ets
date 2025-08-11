//乘车二维码
// import router from '@ohos.router';


//
// @Entry
// @Component
// struct Buspage {
//   @State message: string = 'Hello World';
//
//   build() {
//     Column() {
//       // 顶部导航栏
//       Row() {
//         Image($r('app.media.back1'))
//           .width(24)
//           .height(24)
//           .margin({ left: 16 })
//           .onClick(() => {
//             try {
//               router.back();
//             } catch (err) {
//               console.error('返回失败:', err);
//             }
//           })
//         Text('乘车二维码')
//           .fontSize(20)
//           .fontWeight(FontWeight.Medium)
//           .fontColor($r('sys.color.ohos_id_color_text_primary'))
//           .margin({ left: 12 })
//       }
//       .width('100%')
//       .height(56)
//       .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
//       .alignItems(VerticalAlign.Center)
//       .margin({ top: -20 }) // 向上调整导航栏位置
//
//       // 使用Scroll包裹内容使其可滚动
//       Scroll() {
//         Column() {
//           // 公交车乘车码
//           Column() {
//             Row() {
//               Image($r('app.media.bus1'))
//                 .width(32)
//                 .height(32)
//               Text('公交车乘车码')
//                 .fontSize(24)
//                 .fontWeight(FontWeight.Medium)
//                 .fontColor($r('sys.color.ohos_id_color_text_primary'))
//                 .margin({ left: 12 })
//             }
//             .width('100%')
//             .padding({ left: 16, right: 16, top: 20, bottom: 20 })
//
//             // 公交车二维码
//             Column() {
//               Image($r('app.media.erweima'))
//                 .width(280)
//                 .height(280)
//                 .borderRadius(16)
//                 .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
//             }
//             .width(300)
//             .height(300)
//             .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
//             .borderRadius(20)
//             .justifyContent(FlexAlign.Center)
//             .alignItems(HorizontalAlign.Center)
//           }
//           .margin({ top: 20 })
//
//           // 地铁乘车码
//           Column() {
//             Row() {
//               Image($r('app.media.subway'))
//                 .width(32)
//                 .height(32)
//               Text('地铁乘车码')
//                 .fontSize(24)
//                 .fontWeight(FontWeight.Medium)
//                 .fontColor($r('sys.color.ohos_id_color_text_primary'))
//                 .margin({ left: 12 })
//             }
//             .width('100%')
//             .padding({ left: 16, right: 16, top: 20, bottom: 20 })
//
//             // 地铁二维码
//             Column() {
//               Image($r('app.media.erweima1'))
//                 .width(280)
//                 .height(280)
//                 .borderRadius(16)
//                 .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
//                 .border({
//                   width: 1,
//                   color: $r('sys.color.ohos_id_color_list_separator'),
//                   style: BorderStyle.Solid
//                 })
//             }
//             .width(300)
//             .height(300)
//             .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
//             .borderRadius(20)
//             .justifyContent(FlexAlign.Center)
//             .alignItems(HorizontalAlign.Center)
//           }
//           .margin({ top: 20, bottom: 20 })
//         }
//         .width('100%')
//       }
//       .scrollBar(BarState.Off)
//       .edgeEffect(EdgeEffect.Spring)
//       .width('100%')
//       .layoutWeight(1)
//     }
//     .width('100%')
//     .height('100%')
//     .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
//   }
// }