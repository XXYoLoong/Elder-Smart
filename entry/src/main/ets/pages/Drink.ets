import router from '@ohos.router'
import prompt from '@ohos.prompt'

const STORE_KEY: string = 'WATER_STATE_V1'

/** 持久化状态 */
interface WaterState {
  dateKey: string
  ml: number
  goal: number
}

/** JSON.parse 后的可选字段形状（避免内联对象类型） */
interface WaterPartial {
  dateKey?: string
  ml?: number
  goal?: number
}

/** 保存时的对象形状（避免匿名对象字面量） */
interface WaterSave {
  dateKey: string
  ml: number
  goal: number
}

/** 工具：两位数 */
function pad2(n: number): string { return n < 10 ? `0${n}` : `${n}` }

/** 今天 key */
function todayKey(): string {
  const d: Date = new Date()
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
}

function safeParse<T>(raw: string, fallback: T): T {
  try {
    return JSON.parse(raw) as T
  } catch {
    return fallback
  }
}
/** 读取状态（含健壮性校验与兜底） */
function loadState(): WaterState {
  const fallback: WaterState = { dateKey: todayKey(), ml: 0, goal: 1500 }
  if (!AppStorage.Has(STORE_KEY)) { return fallback }

  const raw: object | string | number | boolean | undefined = AppStorage.Get(STORE_KEY)
  if (typeof raw !== 'string') { return fallback }

  try {
    const parsed: WaterPartial = safeParse<WaterPartial>(raw, {})
    const p: WaterPartial = parsed as WaterPartial

    const okDate: string = (typeof p.dateKey === 'string') ? (p.dateKey as string) : todayKey()
    const okMl: number = (typeof p.ml === 'number' && p.ml >= 0) ? (p.ml as number) : 0
    const okGoal: number = (typeof p.goal === 'number' && p.goal > 0) ? (p.goal as number) : 1500
    const out: WaterState = { dateKey: okDate, ml: okMl, goal: okGoal }
    return out
  } catch {
    return fallback
  }
}

/** 保存状态（显式类型对象） */
function saveState(s: WaterState): void {
  const out: WaterSave = { dateKey: s.dateKey, ml: s.ml, goal: s.goal }
  AppStorage.SetOrCreate(STORE_KEY, JSON.stringify(out))
}

/** 百分比 0~100 */
function percent(ml: number, goal: number): number {
  if (goal <= 0) { return 0 }
  const p: number = Math.floor((ml * 100) / goal)
  return p < 0 ? 0 : (p > 100 ? 100 : p)
}



@Entry
@Component
struct ShequPage {
  @State private dateKey: string = todayKey()
  @State private ml: number = 0
  @State private goal: number = 1500
  @State private water: WaterState = loadState()
  @State private showGoalEditor: boolean = false
  @State private goalInput: string = '1500'

  aboutToAppear(): void {
    const s: WaterState = loadState()
    const tk: string = todayKey()
    if (s.dateKey !== tk) {
      this.dateKey = tk
      this.ml = 0
      this.goal = s.goal
      saveState({ dateKey: this.dateKey, ml: this.ml, goal: this.goal })
    } else {
      this.dateKey = s.dateKey
      this.ml = s.ml
      this.goal = s.goal
    }
    this.goalInput = `${this.goal}`
    this.checkAndResetByDate()
  }

  // —— 业务 —— //
  private add(amount: number): void {
    const next: number = this.ml + amount
    this.ml = next < 0 ? 0 : next
    this.dateKey = todayKey()
    saveState({ dateKey: this.dateKey, ml: this.ml, goal: this.goal })
    if (this.ml >= this.goal) { prompt.showToast({ message: '今天的饮水目标已达成🎉' }) }
  }

  private setGoalFromInput(): void {
    const n: number = parseInt(this.goalInput)
    if (isNaN(n) || n <= 0) {
      prompt.showToast({ message: '请输入有效的目标（>0）' })
      return
    }
    this.goal = n
    this.showGoalEditor = false
    saveState({ dateKey: this.dateKey, ml: this.ml, goal: this.goal })
    prompt.showToast({ message: `目标已设为 ${this.goal} ml` })
  }

  private resetToday(): void {
    this.ml = 0
    this.dateKey = todayKey()
    saveState({ dateKey: this.dateKey, ml: this.ml, goal: this.goal })
    prompt.showToast({ message: '今日计数已重置' })
  }

  private checkAndResetByDate(): void {
    const today: string = todayKey()
    if (this.water.dateKey !== today) {
      // 新的一天 → 重置
      this.water.dateKey = today
      this.water.ml = 0
      saveState(this.water)
    }
  }



  // —— UI —— //
  build() {
    // 只有一个根：Stack，把主体与弹层包在一起
    Stack() {
      // 主体页面
      Column() {
        // 顶部栏
        Row() {
          Image($r('app.media.back1'))
            .width(24).height(24).margin({ left: 16 })
            .onClick((): void => { try { router.back() } catch (err) { console.error('返回失败:', err) } })

          Text('喝水助手')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .margin({ left: 12 })
            .onClick((): void => { try { router.back() } catch (err) { console.error('返回失败:', err) } })

          Blank()

          Button('目标', { type: ButtonType.Capsule })
            .margin({ right: 16 })
            .onClick((): void => { this.goalInput = `${this.goal}`; this.showGoalEditor = true })
        }
        .width('100%')
        .height(56)
        .backgroundColor('#FFFFFF')
        .alignItems(VerticalAlign.Center)
        .margin({ top: -20 })

        // 主体内容
        Column() {
          // 今日进度卡
          Column() {
            Text('今日饮水').fontSize(16).fontColor('#666666')
            Text(`${this.ml} / ${this.goal} ml`).fontSize(36).fontWeight(FontWeight.Bold).margin({ top: 6 })

            Progress({ value: percent(this.ml, this.goal) })
              .width('92%').height(12).margin({ top: 12 }).style({ strokeWidth: 12 })

            Text(`已完成 ${percent(this.ml, this.goal)}%`)
              .fontSize(14).fontColor('#666666').margin({ top: 8 })
          }
          .width('92%').padding(20).backgroundColor('#E6F2FF').borderRadius(12).margin({ top: 20 })

          // 快捷加水
          Column() {
            Text('快捷加水').fontSize(16).fontColor('#1A1A1A')
            Row() {
              Button('+200ml', { type: ButtonType.Capsule }).onClick((): void => this.add(200))
              Button('+300ml', { type: ButtonType.Capsule }).margin({ left: 10 }).onClick((): void => this.add(300))
              Button('+500ml', { type: ButtonType.Capsule }).margin({ left: 10 }).onClick((): void => this.add(500))
            }.margin({ top: 10 })
          }
          .width('92%').padding(16).backgroundColor('#FFFFFF').borderRadius(12).margin({ top: 16 })

          // 调整/重置
          Column() {
            Text('调整')
              .fontSize(16)
              .fontColor('#1A1A1A')
            Row() {
              Button('  -100ml  ', { type: ButtonType.Capsule })
                .onClick((): void => this.add(-100))
              Button(' 重置今日 ', { type: ButtonType.Capsule })
                .margin({ left: 10 })
                .onClick((): void => this.resetToday())
            }.margin({ top: 10 }) }
          .width('92%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ top: 16 })

          Column() {
            Text('小贴士').fontSize(16).fontColor('#1A1A1A')
            Text('• 建议分多次少量饮水，避免一次性大量饮水。').fontSize(14).fontColor('#666666').margin({ top: 6 })
            Text('• 清晨起床、运动后、睡前各补充 200~300 ml 为宜。').fontSize(14).fontColor('#666666').margin({ top: 4 })
          }
          .width('92%').padding(16).backgroundColor('#FFFFFF').borderRadius(12).margin({ top: 16, bottom: 20 })
        }
        .width('100%').alignItems(HorizontalAlign.Center).layoutWeight(1)

        Blank().height(8)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

      // 弹层（遮罩 + 卡片），放在同一个 Stack 根中
      if (this.showGoalEditor) {
        // 遮罩
        Column() {}
        .width('100%').height('100%')
        .backgroundColor('#000000')
        .opacity(0.35)
        .onClick((): void => { this.showGoalEditor = false })

        // 卡片
        Column() {
          Text('设置每日目标（ml）').fontSize(18).fontWeight(FontWeight.Medium)

          TextInput({ placeholder: '例如：2000', text: this.goalInput })
            .width('100%').height(44).margin({ top: 12 }).type(InputType.Number)
            .onChange((v: string): void => { this.goalInput = v })

          Row() {
            Button('取消', { type: ButtonType.Capsule }).onClick((): void => { this.showGoalEditor = false })
            Blank()
            Button('确定', { type: ButtonType.Capsule }).onClick((): void => this.setGoalFromInput())
          }
          .width('100%').margin({ top: 14 })
        }
        .width('86%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .alignItems(HorizontalAlign.Center)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-43%', y: -90 })
      }
    } // end Stack
  }
}
