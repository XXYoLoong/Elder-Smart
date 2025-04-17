import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = 'HarmonyCare智慧康养系统'
  private timer: number | undefined = undefined;  // 存储定时器 ID

  build() {
    Column() {
      // 图片部分
      Column() {
        Image($r('app.media.img'))
          .width("100%")
          .height("100%")
          .alignSelf(ItemAlign.Center) // 确保图片居中
      }
      .width("100%")
      .height("100%")
      .alignItems(HorizontalAlign.Center)

      // 文本部分
      Text(this.message)
        .fontSize("50fp")
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .width("100%")
        .margin({ top: -200 }) // 适当调整文本位置
        .alignSelf(ItemAlign.Center)
    }
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Center)
  }

  aboutToAppear() {
    // 延迟 3 秒后执行跳转
    this.timer = setTimeout(() => {
      router.pushUrl({
        url: "pages/page"
      });
    }, 3000);
  }

  onDestroy() {
    // 清除定时器，防止意外崩溃
    if (this.timer) {
      clearTimeout(this.timer);
    }
  }

  // 页面切换动画
  pageTransition() {
    PageTransitionEnter({ duration: 1000, curve: Curve.Ease }).opacity(1)// 入场动画
    PageTransitionExit({ duration: 1000, curve: Curve.Ease }).slide(SlideEffect.Bottom) // 出场动画
  }
}
