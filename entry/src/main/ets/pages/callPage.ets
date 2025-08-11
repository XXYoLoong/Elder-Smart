import router from '@ohos.router'
import { call } from '@kit.TelephonyKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import promptAction from '@ohos.promptAction'
import dataPreferences from '@ohos.data.preferences'
import deviceInfo from '@ohos.deviceInfo'

interface Contact {
  name: string
  phone: string
  label?: string
  color?: string
}

const PREF_NAME: string = 'emergency_contacts_prefs'
const PREF_KEY: string = 'contacts'

@Entry
@Component
struct CallPage {
  @State contacts: Contact[] = []

  // 内嵌弹层状态（替代 CustomDialog）
  @State showAdd: boolean = false
  @State newName: string = ''
  @State newPhone: string = ''
  @State newLabel: string = '紧急联系人'

  async aboutToAppear(): Promise<void> {
    await this.loadContacts()
    if (this.contacts.length === 0) {
      this.contacts = [
        { name: '父亲', phone: '13800000001', label: '紧急联系人', color: '#FF4D4D' },
        { name: '母亲', phone: '13800000002', label: '紧急联系人', color: '#4D7FFF' },
        { name: '班主任', phone: '13800000003', label: '紧急联系人', color: '#47C88A' },
      ]
      await this.saveContacts()
    }
  }

  private async getPrefs(): Promise<dataPreferences.Preferences> {
    const ctx = getContext(this) as common.UIAbilityContext
    return await dataPreferences.getPreferences(ctx, PREF_NAME)
  }

  private async loadContacts(): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await this.getPrefs()
      const raw: string = await prefs.get(PREF_KEY, '[]') as string

      let parsed: Contact[] = []
      try {
        const tmp = JSON.parse(raw) as Contact[]
        if (Array.isArray(tmp)) parsed = tmp
      } catch (_e) { parsed = [] }

      const list: Contact[] = []
      for (let i = 0; i < parsed.length; i++) {
        const c = parsed[i]
        const item: Contact = {
          name: typeof c.name === 'string' ? c.name : '',
          phone: typeof c.phone === 'string' ? c.phone : '',
          label: typeof c.label === 'string' ? c.label : '紧急联系人',
          color: typeof c.color === 'string' ? c.color : this.pickColor(i)
        }
        if (item.name && item.phone) list.push(item)
      }
      this.contacts = list
    } catch (e) {
      console.error('[CallPage] loadContacts error:', e)
    }
  }

  private async saveContacts(): Promise<void> {
    try {
      const prefs: dataPreferences.Preferences = await this.getPrefs()
      await prefs.put(PREF_KEY, JSON.stringify(this.contacts))
      await prefs.flush()
    } catch (e) {
      console.error('[CallPage] saveContacts error:', e)
    }
  }

  private normalizePhone(v: string): string {
    return v.replace(/\s|-/g, '')
  }

  private validPhone(v: string): boolean {
    return /^\+?\d[\d\s-]{5,}$/.test(v.trim())
  }

  private pickColor(i: number): string {
    const palette: string[] = ['#FF4D4D', '#4D7FFF', '#47C88A', '#FF8F3D', '#6E59D9', '#00B2B2']
    return palette[i % palette.length]
  }

  // 拨号，增加设备/能力兜底
  private async makePhoneCall(phone: string): Promise<void> {
    // 模拟器/非电话设备大概率不支持
    if (deviceInfo.deviceType !== 'phone' && deviceInfo.deviceType !== '2in1') {
      promptAction.showToast({ message: '当前设备不支持拨号（请在真机上测试）' })
      return
    }
    const ctx = getContext(this) as common.UIAbilityContext
    const normalized: string = this.normalizePhone(phone)
    try {
      await call.makeCall(ctx, normalized)
      console.info(`[CallPage] makeCall success: ${normalized}`)
    } catch (err) {
      const be = err as BusinessError
      console.error(`[CallPage] makeCall fail -> ${JSON.stringify(be)}`)
      // 常见：The specified ability does not exist.（模拟器无拨号器）
      promptAction.showToast({ message: `拨号失败：${be.message ?? be.toString()}` })
    }
  }

  private async addContact(): Promise<void> {
    const name = this.newName.trim()
    const phone = this.newPhone.trim()
    const label = (this.newLabel || '紧急联系人').trim()
    if (!name) { promptAction.showToast({ message: '请输入姓名' }); return }
    if (!this.validPhone(phone)) { promptAction.showToast({ message: '请输入有效的电话号码' }); return }

    const c: Contact = { name, phone, label, color: this.pickColor(this.contacts.length) }
    this.contacts = [c, ...this.contacts]
    await this.saveContacts()
    this.newName = ''; this.newPhone = ''; this.newLabel = '紧急联系人'
    this.showAdd = false
    promptAction.showToast({ message: '已添加' })
  }

  private async removeContact(idx: number): Promise<void> {
    if (idx < 0 || idx >= this.contacts.length) { return }
    this.contacts.splice(idx, 1)
    this.contacts = [...this.contacts]
    await this.saveContacts()
    promptAction.showToast({ message: '已删除' })
  }

  build() {
    // 单根容器：Stack，用来叠放主界面与半透明弹层
    Stack() {

      // ===== 主界面 =====
      Column() {
        // 顶部栏
        Row() {
          Image($r('app.media.back1'))
            .width(24).height(24)
            .margin({ left: 16 })
            .onClick((): void => {
              try { router.back() } catch (err) { console.error('返回失败:', err) }
            })

          Text('紧急呼叫')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .margin({ left: 12 })

          Blank()

          // 右上角加号（无资源时用“+”）
          Text('+')
            .fontSize(22)
            .margin({ right: 16 })
            .onClick((): void => { this.showAdd = true })
        }
        .width('100%').height(56)
        .backgroundColor('#FFFFFF')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .margin({ top: -20 })

        // 列表
        Scroll() {
          Column() {
            ForEach(this.contacts, (c: Contact, idx: number) => {
              Row() {
                // 左侧圆形“呼叫”
                Column() {
                  Image($r('app.media.person')).width(60).height(60)
                  Text('呼叫').fontSize(16).fontColor('#1A1A1A').margin({ top: 4 })
                }
                .backgroundColor('#F5F5F5')
                .borderRadius(30)
                .padding(10)
                .margin({ right: 16 })
                .onClick((): void => { this.makePhoneCall(c.phone).then(() => {}).catch(() => {}) })

                // 右侧信息卡
                Column() {
                  Text(c.label ?? '紧急联系人').fontSize(14).fontColor('#FFFFFF')
                  Text(c.name).fontSize(20).fontColor('#FFFFFF').margin({ top: 4 })
                  Text(c.phone).fontSize(18).fontColor('#FFFFFF').margin({ top: 4 })
                }
                .backgroundColor(c.color ?? '#FF4D4D')
                .borderRadius(12)
                .padding(16)
                .layoutWeight(1)
                .onClick((): void => { this.makePhoneCall(c.phone).then(() => {}).catch(() => {}) })
                .gesture(
                  LongPressGesture({ repeat: false })  // 长按删除
                    .onAction((): void => { this.removeContact(idx).then(() => {}).catch(() => {}) })
                )
              }
              .width('90%')
              .margin({ top: 18 })
            }, (c: Contact, i: number) => `${i}_${c.phone}`)

            Blank().height(24)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')

      // ===== 叠层弹窗（新增联系人） =====
      if (this.showAdd) {
        // 半透明遮罩
        Column() {
          // 点击遮罩关闭
          Blank().layoutWeight(1).width('100%').onClick((): void => { this.showAdd = false })

          // 弹层卡片
          Column() {
            Text('新增紧急联系人')
              .fontSize(18).fontWeight(FontWeight.Medium).margin({ bottom: 12 })

            Text('姓名').fontSize(14).fontColor('#666')
            TextInput({ placeholder: '例如：父亲' })
              .width('100%').height(40).margin({ bottom: 8 })
              .onChange((v: string): void => { this.newName = v })

            Text('电话号码').fontSize(14).fontColor('#666')
            TextInput({ placeholder: '例如：13800000000' })
              .type(InputType.PhoneNumber)
              .width('100%').height(40).margin({ bottom: 8 })
              .onChange((v: string): void => { this.newPhone = v })

            Text('标签').fontSize(14).fontColor('#666')
            TextInput({ text: this.newLabel, placeholder: '紧急联系人/家人/医生...' })
              .width('100%').height(40).margin({ bottom: 12 })
              .onChange((v: string): void => { this.newLabel = v })

            Row() {
              Button('取消').type(ButtonType.Normal).onClick((): void => { this.showAdd = false }).layoutWeight(1)
              Button('保存').type(ButtonType.Capsule).onClick((): void => { this.addContact() }).layoutWeight(1)
            }.width('100%')
          }
          .width('88%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({ radius: 16, color: '#22000000', offsetX: 0, offsetY: 4 })

          Blank().layoutWeight(1).width('100%')
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#66000000')
      }
    }
    .width('100%')
    .height('100%')
  }
}
