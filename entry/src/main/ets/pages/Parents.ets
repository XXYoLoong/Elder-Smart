import first from '../common/parents/first';
import second from '../common/parents/second';
import third from '../common/parents/third';


@Entry
@Component
struct OldIndex {

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        // Home Tab - Navigate to First Page
        TabContent() {
          first()
        }
        .linearGradient({
          direction: GradientDirection.Bottom,  // 设置渐变方向
          colors: []  // 如果不需要颜色，可以传递空数组
        })
        .tabBar({ icon: $r('app.media.109'), text: "首页" })

        // Rehabilitation Tab - Navigate to Third Page
        TabContent() {
          third()
        }
        .linearGradient({
          direction: GradientDirection.Bottom,  // 设置渐变方向
          colors: []  // 如果不需要颜色，可以传递空数组
        })
        .tabBar({ icon: $r('app.media.110'), text: "医疗档案" })

        // Mine Tab - User Profile Page
        TabContent() {
          second()
        }
        .linearGradient({
          direction: GradientDirection.Bottom,  // 设置渐变方向
          colors: []  // 如果不需要颜色，可以传递空数组
        })
        .tabBar({ icon: $r('app.media.111'), text: "个人中心" })
      }
      .width("100%")
      .height("100%")
      .barHeight("8%")
    }
    .width("100%")
    .height("100%")
  }
}
