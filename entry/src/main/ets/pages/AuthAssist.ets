import router from '@ohos.router'
import prompt from '@ohos.prompt'
import { db } from '../signup/Database'
// 你的项目里若有 Account 类就保留导入；否则用下面 AccountRow 接口
import { Account } from '../signup/Account'

type AssistMode = 'register' | 'forgot'

// 账户表行结构
interface AccountRow {
  id: number
  username: string
  password: string
}

// 期望的强类型表接口
interface AccountTable {
  select(id: number): AccountRow | undefined
  insert(row: AccountRow): void
  update(row: AccountRow): void
}

// 运行期收窄用的“弱类型”形状（用 interface 而非 type）
interface AccountTableLike {
  select?: (id: number) => AccountRow | undefined
  insert?: (row: AccountRow) => void
  update?: (row: AccountRow) => void
}


/** 从 db 拿表并做类型收窄：拿不到或缺方法就返回 undefined */
function getAccountTable(): AccountTable | undefined {
  const raw: AccountTableLike | null =
    (db && db.tables && db.tables.get)
      ? (db.tables.get('Account') as AccountTableLike)
      : null

  if (!raw) return undefined

  const okSelect = typeof raw.select === 'function'
  const okInsert = typeof raw.insert === 'function'
  const okUpdate = typeof raw.update === 'function'

  if (okSelect && okInsert && okUpdate) {
    return raw as AccountTable
  }
  return undefined
}


@Entry
@Component
struct AuthAssist {
  @State private mode: AssistMode = 'register'     // 由路由参数决定
  @State private username: string = ''
  @State private password: string = ''             // 注册/新密码
  @State private confirmPwd: string = ''           // 忘记密码时使用
  @State private submitting: boolean = false

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string> | undefined
    if (params) {
      const m = params['mode']
      if (m === 'forgot' || m === 'register') this.mode = m
      const pf = params['prefill']
      if (typeof pf === 'string' && pf.length > 0) this.username = pf
    }
  }

  private get title(): string {
    return this.mode === 'forgot' ? '忘记密码' : '注册界面'
  }
  private get subtitle(): string {
    return this.mode === 'forgot' ? '重置你的登录密码' : '注册账号使用更多服务'
  }
  private get submitText(): string {
    return this.submitting ? '处理中…' : (this.mode === 'forgot' ? '重置密码' : '注册')
  }

  // —— 校验 —— //
  private validateRegister(): boolean {
    if (!this.username.trim()) { prompt.showToast({ message: '请输入用户名' }); return false }
    if (this.password.length < 4) { prompt.showToast({ message: '密码至少 4 位' }); return false }
    return true
  }
  private validateForgot(): boolean {
    if (!this.username.trim()) { prompt.showToast({ message: '请输入用户名' }); return false }
    if (this.password.length < 4) { prompt.showToast({ message: '新密码至少 4 位' }); return false }
    if (this.password !== this.confirmPwd) { prompt.showToast({ message: '两次输入的密码不一致' }); return false }
    return true
  }

  // —— 数据操作 —— //
  private doRegister(): void {
    if (!this.validateRegister() || this.submitting) return
    this.submitting = true
    const table = getAccountTable()
    if (!table) { prompt.showToast({ message: '系统错误：Account 表不存在或方法缺失' }); this.submitting = false; return }

    // 你的示例一直用 id=1，这里保持一致；若要支持多用户，自行生成/查询 id
    const row: AccountRow = { id: 1, username: this.username.trim(), password: this.password }
    try {
      table.insert(row)
      prompt.showToast({ message: '注册成功' })
      router.pushUrl({ url: 'pages/login' })
    } catch (e) {
      console.error('[AuthAssist] register error:', e as object)
      prompt.showToast({ message: '注册失败，请稍后再试' })
    } finally {
      this.submitting = false
    }
  }

  private doReset(): void {
    if (!this.validateForgot() || this.submitting) return
    this.submitting = true
    const table = getAccountTable()
    if (!table) { prompt.showToast({ message: '系统错误：Account 表不存在或方法缺失' }); this.submitting = false; return }

    try {
      const existed: AccountRow | undefined = table.select(1)
      const finalRow: AccountRow = {
        id: 1,
        username: this.username.trim() || (existed ? existed.username : ''),
        password: this.password
      }
      // 若库不保证 upsert，这里直接调用 update；失败可回退为 insert
      try {
        table.update(finalRow)
      } catch (_e) {
        table.insert(finalRow)
      }
      prompt.showToast({ message: '密码已重置' })
      router.pushUrl({ url: 'pages/login' })
    } catch (e) {
      console.error('[AuthAssist] reset error:', e as object)
      prompt.showToast({ message: '重置失败，请稍后再试' })
    } finally {
      this.submitting = false
    }
  }

  private onSubmit(): void {
    if (this.mode === 'forgot') this.doReset()
    else this.doRegister()
  }

  // —— UI —— //
  build() {
    Column() {
      // 顶部
      Column() {
        Image($r('app.media.img1')).width(78).height(78).margin({ top: 36 })
        Text(this.title).fontSize(24).margin({ top: 8 })
        Text(this.subtitle).fontSize(16).fontColor('#99182431').margin({ top: 4 })
      }
      .width('100%').alignItems(HorizontalAlign.Center)

      // 表单
      Column() {
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .width('86%').height(48).type(InputType.Normal)
          .margin({ top: 24 })
          .onChange((v: string): void => { this.username = v })

        TextInput({
          placeholder: this.mode === 'forgot' ? '请输入新密码' : '请输入密码',
          text: this.password
        })
          .width('86%').height(48).type(InputType.Password)
          .margin({ top: 12 })
          .onChange((v: string): void => { this.password = v })

        if (this.mode === 'forgot') {
          TextInput({ placeholder: '请再次输入新密码', text: this.confirmPwd })
            .width('86%').height(48).type(InputType.Password)
            .margin({ top: 12 })
            .onChange((v: string): void => { this.confirmPwd = v })
        }

        Button(this.submitText, { type: ButtonType.Capsule })
          .width('86%').height(44).margin({ top: 20 })
          .enabled(!this.submitting)
          .onClick((): void => this.onSubmit())

        Row() {
          Text('返回登录').fontColor('#2E7DFF').fontSize(16)
            .onClick(() => router.pushUrl({ url: 'pages/login' }))
        }
        .width('100%').justifyContent(FlexAlign.Center).margin({ top: 16 })
      }
      .width('100%').alignItems(HorizontalAlign.Center)
    }
    .width('100%').height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}
