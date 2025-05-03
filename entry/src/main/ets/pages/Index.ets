import router from '@ohos.router';
import CommonConstants from '../common/constants/CommonConstants';

@Entry
@Component
struct Index {

  @State message1: string = ' ElderSmart+'
  @State message2: string = '乐龄智伴'
  @State visible: Visibility = Visibility.None;
  scroller: Scroller = new Scroller();
  private pointsArr: string[] = ['400vp', '600vp', '800vp'];

  build() {
    Stack() {
      Column() {
        Column() {
          Image($r('app.media.img'))
            .width("100%")
            .height("100%")
            .objectFit(ImageFit.Cover)
        }
        .width("100%")
        .height("100%")

        Text(`${this.message1}`)
          .width("300vp")
          .height("60vp")
          .offset({ x: "-90px", y: "-2046.91px" })
          .textAlign(TextAlign.Center)
          .fontSize("40fp")
          .fontWeight(FontWeight.Bold)
        Text(`${this.message2}`)
          .width("300vp")
          .height("60vp")
          .offset({ x: "-90px", y: "-2090.91px" })
          .textAlign(TextAlign.Center)
          .fontSize("30fp")
          .fontWeight(FontWeight.Bold)
      }
      .width("100%")
      .height("100%")
      .alignItems(HorizontalAlign.End)

      Column() {
        GridRow({
          columns: {
            xs: CommonConstants.JANUARY,
            sm: CommonConstants.FOUR,
            md: CommonConstants.EIGHT,
            lg: CommonConstants.TWELVES
          },
          breakpoints: {
            value: this.pointsArr,
            reference: BreakpointsReference.WindowSize
          }
        }) {
          GridCol({
            span: {
              xs: CommonConstants.JANUARY,
              sm: CommonConstants.GRID_COUNT,
              md: CommonConstants.FOUR,
              lg: CommonConstants.EIGHT
            },
            offset: {
              xs: CommonConstants.ZERO,
              sm: CommonConstants.JANUARY,
              md: CommonConstants.GRID_COUNT,
              lg: CommonConstants.GRID_COUNT
            }
          }) {
            Column() {
              Text($r('app.string.button_name2'))
                .height($r('app.float.button_height1'))
                .fontSize($r('app.float.font_size3'))
                .fontWeight(FontWeight.Bold)

              Scroll(this.scroller) {
                Text() {
                  Span($r('app.string.word1'))
                  Span($r('app.string.toast_text'))
                    .fontColor(Color.Orange)
                    .fontWeight(FontWeight.Bold)
                    .decoration({ type: TextDecorationType.Underline, color: Color.Orange })
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/Index'
                      })
                    })
                  Span($r('app.string.word2'))
                }
                .fontSize($r('app.float.font_size1'))
                .padding({
                  left: $r('app.float.column_padding'),
                  right: $r('app.float.column_padding')
                })
              }
              .scrollable(ScrollDirection.Vertical)
              .height($r('app.float.dialog_height'))

              Row({ space: CommonConstants.SPACE_ONE }) {
                Button($r('app.string.disagree'), { stateEffect: false, buttonStyle: ButtonStyleMode.TEXTUAL })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/Index'
                    })
                  })
                  .width(CommonConstants.FORTY_PERCENT)
                Button($r('app.string.agreed'), { type: ButtonType.Capsule })
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/login'  // 跳转到目标页面
                    });
                    // if (this.visible === Visibility.Visible) {
                    //   this.visible = Visibility.None;
                    // } else {
                    //   this.visible = Visibility.Visible;
                    // }
                  })
                  .width(CommonConstants.FORTY_PERCENT)
              }
              .alignItems(VerticalAlign.Top)
              .margin({ top: $r('app.float.border_radius1') })
              .height($r('app.float.button_height1'))
            }
            .backgroundColor(Color.White)
            .visibility(this.visible)
            .borderRadius($r('app.float.border_radius3'))
            .width($r('app.float.bind_sheet_height'))
          }
        }
      }
      .width(CommonConstants.NINETY_FIVE_PERCENT)


    }
  }
  aboutToAppear() {
    //延迟五秒钟 做一个操作
    setTimeout(() => {
      this.visible = Visibility.Visible;  // 显示弹窗
      // //操作的内容->跳转
      // router.pushUrl({
      //   url: "pages/page"
      // });
    }, 3000)
  }
  //跳转时候动画
  pageTransition() {
    //入场动画
    PageTransitionEnter({ duration: 2000, curve: Curve.Friction }).slide(SlideEffect.Left)
    //出场动画
    PageTransitionExit({ duration: 2000, curve: Curve.Smooth }).slide(SlideEffect.Bottom)
  }
}

function terminateSelf() {
  throw new Error('Function not implemented.');
}
