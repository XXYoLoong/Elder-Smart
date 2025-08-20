import router from '@ohos.router';
import { common } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';
import Want from '@ohos.app.ability.Want';

// 统一只从 PrefStore 拿需要的函数
import { loadProfile, Profile } from '../common/PrefStore';

@Entry
@Component
struct MinePage {
  @State private nickname: string = '加载中…';
  @State private city: string = '';
  @State private avatarUri: string = '';
  @State private todaySteps: number = 0;

  private getCtx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  // aboutToAppear 里使用同步版本
  aboutToAppear(): void {
    const p: Profile = loadProfile()
    this.nickname = p.nickname
    this.city = p.city
    this.avatarUri = p.avatarUri

    const base = 3800
    const rnd = Math.floor(Math.random() * 1200)
    this.todaySteps = base + rnd
  }

  // —— 动作：打开系统钱包（可用则拉起，不可用则 Toast 兜底）——
  private async openWallet(): Promise<void> {
    try {
      const want: Want = { uri: 'hwwallet://wallet' };
      await this.getCtx().startAbility(want);
    } catch (_e) {
      promptAction.showToast({ message: '未检测到系统钱包，将尝试打开网页' });
      try {
        await this.getCtx().startAbility({ uri: 'https://idpay.huawei.com/' });
      } catch (_e2) {
        promptAction.showToast({ message: '无法打开钱包入口' });
      }
    }
  }

  // —— 动作：意见反馈（mailto）——
  private async feedback(): Promise<void> {
    const subject = encodeURIComponent('WiseCare 用户反馈');
    const body = encodeURIComponent('请填写你的问题/建议：');
    const want: Want = { uri: `mailto:chayunyoloong@gamil.com?subject=${subject}&body=${body}` };
    try {
      await this.getCtx().startAbility(want);
    } catch (_e) {
      promptAction.showToast({ message: '未发现邮件应用，尝试打开网页邮箱' });
      this.getCtx().startAbility({ uri: 'https://mail.google.com/' }).catch(() => { /* 忽略 */ });
    }
  }

  private logout(): void {
    promptAction.showToast({ message: '已退出' });
    router.replaceUrl({ url: 'pages/login' });
  }

  private toEdit(): void { router.pushUrl({ url: 'pages/ProfileEdit' }); }
  private toDetail(): void { router.pushUrl({ url: 'pages/ProfileDetail' }); }
  private toSettings(): void { router.pushUrl({ url: 'pages/SettingsPage' }); }

  build() {
    Column() {
      // 顶部设置
      Row() {
        Blank()
        Image($r('app.media.settings')).width(24).height(24).margin({ right: 16 })
          .onClick(() => this.toSettings())
      }
      .width('100%').height(56).backgroundColor('#FFFFFF').margin({ top: -20 })

      // 主体
      Scroll() {
        Column() {
          // 个人信息
          Column() {
            if (this.avatarUri && this.avatarUri.length > 0) {
              Image(this.avatarUri).width(100).height(100).borderRadius(50).margin({ top: 20 })
                .objectFit(ImageFit.Cover).onClick(() => this.toDetail())
            } else {
              Image($r('app.media.wo')).width(100).height(100).borderRadius(50).margin({ top: 20 })
                .onClick(() => this.toDetail())
            }

            Text(this.nickname).fontSize(24).fontWeight(FontWeight.Medium).margin({ top: 16 })

            Row() {
              Button(`IP：${this.city}`)
                .fontSize(16).fontColor('#1A1A1A')
                .backgroundColor('#FFE4E1').borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              Button('编辑资料')
                .fontSize(16).fontColor('#1A1A1A')
                .backgroundColor('#FFE4E1').borderRadius(16)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ left: 16 }).onClick((): void => this.toEdit())
            }
            .margin({ top: 16 })
          }
          .width('100%').padding({ bottom: 20 })

          // 功能列表
          Column() {
            // 今日步数
            Row() {
              Row() {
                Image($r('app.media.steps')).width(24).height(24)
                Text(`今日步数：${this.todaySteps}`).fontSize(16).fontColor('#1A1A1A').margin({ left: 12 })
              }
              Image($r('app.media.right')).width(20).height(20)
            }
            .width('100%').height(60).padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            .onClick(() => promptAction.showToast({ message: `今日步数 ${this.todaySteps}` }))

            // 支付
            Row() {
              Row() {
                Image($r('app.media.wallet')).width(24).height(24)
                Text('支付').fontSize(16).fontColor('#1A1A1A').margin({ left: 12 })
              }
              Image($r('app.media.right')).width(20).height(20)
            }
            .width('100%').height(60).padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            .onClick(() => { this.openWallet().then(() => {}).catch(() => {}) })

            // 意见反馈
            Row() {
              Row() {
                Image($r('app.media.feedback')).width(24).height(24)
                Text('意见反馈').fontSize(16).fontColor('#1A1A1A').margin({ left: 12 })
              }
              Image($r('app.media.right')).width(20).height(20)
            }
            .width('100%').height(60).padding({ left: 16, right: 16 })
            .backgroundColor('#FFFFFF').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
            .onClick(() => { this.feedback().then(() => {}).catch(() => {}) })
          }
          .margin({ top: 20 })

          // 退出登录
          Button('退出登录')
            .width('90%').height(50).fontSize(18).fontColor('#FFFFFF')
            .backgroundColor($r('sys.color.ohos_id_color_warning'))
            .borderRadius(25).margin({ top: 40, bottom: 20 })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Index'
              })
            })
          //.onClick((): void => this.logout())
        }
        .width('100%')
      }
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      .width('100%').layoutWeight(1)

      // 底部导航
      Row() {
        Column() {
          Image($r('app.media.home2')).width(25).height(25)
          Text('首页').fontSize(14).fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 4 })
        }
        .onClick(() => {
          router.replaceUrl({ url: 'pages/Oldman', params: { from: 'mine' } })
        })

        Button() {
          Image($r('app.media.gongyi')).width(50).height(50)
        }
        .width(60).height(60)
        .backgroundColor('#fff5d1d1')
        .borderRadius(30)

        Column() {
          Image($r('app.media.user2')).width(25).height(25)
          Text('我的').fontSize(14).fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 4 })
        }
      }
      .width('100%').height(70).backgroundColor($r('sys.color.ohos_id_color_background'))
      .justifyContent(FlexAlign.SpaceEvenly).alignItems(VerticalAlign.Center)
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
