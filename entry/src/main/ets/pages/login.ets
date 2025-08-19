import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { db } from '../signup/Database'
import { authentication } from '@kit.AccountKit'
import { util } from '@kit.ArkTS'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct Home {
  // 账号密码
  @State account: string = ''
  @State password: string = ''

  // —— 公共：获取上下文（用于拉起华为账号界面）——
  private getCtx(): common.Context {
    // 在 Stage 模型的 ArkUI 组件中可以直接拿到 UIAbilityContext
    return getContext(this) as common.UIAbilityContext
  }

  // —— 账号密码登录（保留你原逻辑 + Demo 后门）——
  private onLoginByPassword(): void {
    const table = db?.tables?.get?.('Account')
    if (table) {
      const row = table.select(1)
      if (row && this.account === row.username && this.password === row.password) {
        router.pushUrl({ url: 'pages/Oldman' })
        return
      }
    }
    if (this.account === '1' && this.password === '1') {
      router.pushUrl({ url: 'pages/Oldman' })
      return
    }
    promptAction.showToast({ message: '账号或密码错误' })
  }

  // —— 华为账号登录 ——（使用 Account Kit：AuthorizationWithHuaweiIDRequest）
  private async onHuaweiLogin(): Promise<void> {
    try {
      const provider = new authentication.HuaweiIDProvider()
      const req = provider.createAuthorizationWithHuaweiIDRequest()
      // 最小化示例：拿到 openid / unionid，并拿到 idtoken / auth code（可选）
      req.scopes = ['openid']                       // 需要更多信息可加 'profile'、'phone'（需审核）
      req.permissions = ['idtoken', 'serviceauthcode']
      req.forceAuthorization = true
      req.state = util.generateRandomUUID()
      req.idTokenSignAlgorithm = authentication.IdTokenSignAlgorithm.PS256

      const controller = new authentication.AuthenticationController(this.getCtx())
      const resp = await controller.executeRequest(req)
      const authResp = resp as authentication.AuthorizationWithHuaweiIDResponse

      // 校验 state 防重放
      if (authResp.state && authResp.state !== req.state) {
        promptAction.showToast({ message: '登录失败：state 校验不通过' })
        return
      }

      const cred = authResp?.data
      const idToken = cred?.idToken
      const authCode = cred?.authorizationCode
      const openId = cred?.openID
      const unionId = cred?.unionID

      // TODO: 这里把 idToken / authCode 发给你的后端换取会话
      // await http.post('/api/auth/huawei', { idToken, code: authCode, openId, unionId })

      promptAction.showToast({ message: '华为账号登录成功' })
      router.pushUrl({ url: 'pages/Oldman' })
    } catch (e) {
      const err = e as BusinessError
      // 参考官方错误码给出更友好的提示
      const code = (err && (err.code as number)) || -1
      let msg = '登录失败'
      if (code === 1001502012) msg = '已取消登录'
      else if (code === 1001502005) msg = '网络异常，请检查网络'
      else if (code === 12300001) msg = '系统服务异常，请稍后重试'
      else if (code === 1001502001) msg = '未登录华为账号，请登录后重试'
      promptAction.showToast({ message: `${msg}（${code}）` })
      console.error('[HuaweiID] login error:', JSON.stringify(err))
    }
  }

  build() {
    Column() {
      // 顶部 Logo / 标题
      Column() {
        Image($r('app.media.img1'))
          .width(78).height(78).margin({ top: 40 })
        Text('登录界面').fontSize(24).margin({ top: 8 })
        Text('登录账号使用更多服务')
          .fontSize(16).fontColor('#99182431')
      }
      .width('100%').alignItems(HorizontalAlign.Center)

      // 输入框
      Column() {
        TextInput({ placeholder: '请输入账号/手机号', text: this.account })
          .width('86%').height(48).type(InputType.Normal)
          .margin({ top: 24 })
          .onChange((v: string): void => { this.account = v })

        TextInput({ placeholder: '请输入密码', text: this.password })
          .width('86%').height(48).type(InputType.Password)
          .margin({ top: 12 })
          .onChange((v: string): void => { this.password = v })

        // “注册账号” | “忘记密码” —— 并排对称
        // —— 底部辅助操作 —— //
        Row({ space: 24 }) {
          // 注册账号 -> 进入合并页（注册模式）
          Text('注册账号')
            .fontColor('#2E7DFF')
            .fontSize(15)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/AuthAssist',
                params: { mode: 'register' }   // 进入注册模式
              })
            })

          // 忘记密码 -> 进入合并页（忘记密码模式），把当前账号预填过去
          Text('忘记密码')
            .fontColor('#2E7DFF')
            .fontSize(15)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/AuthAssist',
                params: { mode: 'forgot', prefill: this.account }  // this.account 是登录页的账号 State
              })
            })
        }
        .width('86%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 12 })


        // 账号密码登录按钮
        Button('账号登录', { type: ButtonType.Capsule })
          .width('86%').height(44)
          .margin({ top: 16 })
          .onClick((): void => this.onLoginByPassword())
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // 底部：华为账号登录图标按钮（居中）
      Column() {
        Text('或').fontSize(14).fontColor('#94A3B8').margin({ top: 24, bottom: 8 })
        // 使用你的图标资源名称替换 app.media.hw_id
        Image($r('app.media.hw_id'))
          .width(56).height(56)
          .borderRadius(28)
          .interpolation(ImageInterpolation.High)
          .onClick((): void => { this.onHuaweiLogin().then(() => {}).catch(() => {}) })
        Text('华为账号登录').fontSize(14).fontColor('#64748B').margin({ top: 6 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)

      // 底部“去注册”入口（可选，若上面已放“注册账号”，这块也可以保留增强转化）
      // Row() {
      //   Text('没有账号？去注册').fontColor('#2E7DFF').fontSize(16)
      //     .onClick(() => router.pushUrl({ url: 'pages/register' }))
      // }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 16 })
    }
    .width('100%').height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
