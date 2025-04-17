import first from './first';
import second from './second';
import third from './third';

import { router } from '@kit.ArkUI';

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
        .linearGradient({ direction: GradientDirection.Bottom, colors: [[0x007FFF, 0.0], [0xAFEEEE, 0.7]] })
        .tabBar({ icon: $r('app.media.109'), text: "首页" })
      //  .onClick(() => this.pushfirst());

        // Rehabilitation Tab - Navigate to Third Page
        TabContent() {
         third()
        }
        .linearGradient({ direction: GradientDirection.Bottom, colors: [[0x007FFF, 0.0], [0xAFEEEE, 0.7]] })
        .tabBar({ icon: $r('app.media.110'), text: "医疗档案" })
       // .onClick(() => this.pushthird());

        // Mine Tab - User Profile Page
        TabContent() {
          second()
        }
        .linearGradient({ direction: GradientDirection.Bottom, colors: [[0x007FFF, 0.0], [0xAFEEEE, 0.7]] })
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
