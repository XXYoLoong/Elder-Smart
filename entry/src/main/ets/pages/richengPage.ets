// entry/src/main/ets/pages/richengPage.ets
import router from '@ohos.router'
import prompt from '@ohos.prompt'

/** —— 基础类型 —— */
type RepeatMode = 'NONE' | 'DAILY' | 'WEEKLY'

interface Schedule {
  id: number
  title: string
  content: string
  group: string
  level: number        // 0 普通 1 重要 2 紧急
  repeat: RepeatMode
  weekDays: number[]   // WEEKLY 生效，0~6 => 周日~周六
  year: number
  month: number
  day: number
  hour: number
  minute: number
  second: number
}

interface NowParts {
  y: number
  m: number
  d: number
  hh: number
  mm: number
  ss: number
}

interface DateParts {
  y: number
  m: number
  d: number
}

interface MakeScheduleArgs {
  id: number
  title: string
  content: string
  group: string
  level: number
  repeat: RepeatMode
  weekDays: number[]
  y: number
  m: number
  d: number
  hh: number
  mm: number
  ss: number
}

/** —— Schedule 实体类（避免对象字面量直接入栈） —— */
class Sched implements Schedule {
  id: number
  title: string
  content: string
  group: string
  level: number
  repeat: RepeatMode
  weekDays: number[]
  year: number
  month: number
  day: number
  hour: number
  minute: number
  second: number
  constructor(a: MakeScheduleArgs) {
    this.id = a.id
    this.title = a.title
    this.content = a.content
    this.group = a.group
    this.level = a.level
    this.repeat = a.repeat
    this.weekDays = a.repeat === 'WEEKLY' ? a.weekDays.slice() : []
    this.year = a.y
    this.month = a.m
    this.day = a.d
    this.hour = a.hh
    this.minute = a.mm
    this.second = a.ss
  }
}

/** —— 常量 —— */
const STORE_KEY: string = 'SCHEDULES_V1'
const LEVEL_TEXT: string[] = ['普通', '重要', '紧急']
const GROUP_OPTIONS: string[] = ['默认', '用药', '体检', '出行', '聚会', '其他']
const REPEAT_OPTIONS: string[] = ['不重复', '每天', '每周']
const WEEK_TEXT: string[] = ['日', '一', '二', '三', '四', '五', '六']
const FILTER_OPTIONS: string[] = ['全部'].concat(GROUP_OPTIONS)

/** —— 工具 —— */
function pad2(n: number): string { return n < 10 ? `0${n}` : `${n}` }

function nowParts(): NowParts {
  const t: Date = new Date()
  return { y: t.getFullYear(), m: t.getMonth() + 1, d: t.getDate(), hh: t.getHours(), mm: t.getMinutes(), ss: t.getSeconds() }
}

function addDays(y: number, m: number, d: number, delta: number): DateParts {
  const dt: Date = new Date(y, m - 1, d)
  dt.setDate(dt.getDate() + delta)
  return { y: dt.getFullYear(), m: dt.getMonth() + 1, d: dt.getDate() }
}

/** —— 选择器数据 —— */
function rangeYears(): string[] { const r: string[] = []; let y: number = 1970; while (y <= 2100) { r.push(`${y}`); y++ } return r }
function range1toN(n: number): string[] { const r: string[] = []; let i: number = 1; while (i <= n) { r.push(`${i}`); i++ } return r }
function range0toN(n: number): string[] { const r: string[] = []; let i: number = 0; while (i <= n) { r.push(`${i}`); i++ } return r }
const YEAR_OPTS: string[] = rangeYears()
const MONTH_OPTS: string[] = range1toN(12)
function dayOpts(year: number, month: number): string[] { const last: number = new Date(year, month, 0).getDate(); return range1toN(last) }
const HOUR_OPTS: string[] = range0toN(23)
const MIN_OPTS: string[] = range0toN(59)
const SEC_OPTS: string[] = range0toN(59)

/** —— 本地存取 —— */
function loadAll(): Schedule[] {
  try {
    if (!AppStorage.Has(STORE_KEY)) {
      return []
    }

    const raw: string | number | boolean | object | undefined = AppStorage.Get(STORE_KEY)
    if (typeof raw !== 'string') {
      return []
    }

    // 明确告诉 ArkTS 这是 Schedule[]，否则会报 any/unknown
    const arr: Schedule[] = JSON.parse(raw) as Schedule[]
    if (!Array.isArray(arr)) {
      return []
    }

    const out: Schedule[] = []
    for (let i: number = 0; i < arr.length; i++) {
      const s: Schedule = arr[i]
      if (!s || typeof s.id !== 'number' || typeof s.title !== 'string') {
        continue
      }

      const sc: Schedule = {
        id: s.id,
        title: s.title,
        content: typeof s.content === 'string' ? s.content : '',
        group: typeof s.group === 'string' ? s.group : '默认',
        level: typeof s.level === 'number' ? s.level : 0,
        repeat: (s.repeat === 'DAILY' || s.repeat === 'WEEKLY') ? s.repeat : 'NONE',
        weekDays: Array.isArray(s.weekDays)
          ? s.weekDays.filter((n: number): boolean => typeof n === 'number')
          : [],
        year: typeof s.year === 'number' ? s.year : nowParts().y,
        month: typeof s.month === 'number' ? s.month : nowParts().m,
        day: typeof s.day === 'number' ? s.day : nowParts().d,
        hour: typeof s.hour === 'number' ? s.hour : 9,
        minute: typeof s.minute === 'number' ? s.minute : 0,
        second: typeof s.second === 'number' ? s.second : 0
      }
      out.push(sc)
    }

    return out
  } catch {
    return []
  }
}


function saveAll(list: Schedule[]): void { AppStorage.SetOrCreate(STORE_KEY, JSON.stringify(list)) }

/** —— 预置 8 条 —— */
function makeSchedule(a: MakeScheduleArgs): Schedule { return new Sched(a) }

function seed8(): Schedule[] {
  const n: NowParts = nowParts()
  const d1: DateParts = addDays(n.y, n.m, n.d, 0)
  const d3: DateParts = addDays(n.y, n.m, n.d, 2)
  const d5: DateParts = addDays(n.y, n.m, n.d, 4)
  const d8: DateParts = addDays(n.y, n.m, n.d, 7)
  // 其余中间天数不直接用
  return [
    makeSchedule({ id: 1, title: '量血压', content: '晨起先量，记录波动', group: '体检', level: 1, repeat: 'DAILY', weekDays: [], y: d1.y, m: d1.m, d: d1.d, hh: 7, mm: 0, ss: 0 }),
    makeSchedule({ id: 2, title: '饭后吃药', content: '午餐后半小时', group: '用药', level: 2, repeat: 'DAILY', weekDays: [], y: d1.y, m: d1.m, d: d1.d, hh: 12, mm: 30, ss: 0 }),
    makeSchedule({ id: 3, title: '广场舞', content: '跟邻居一起跳', group: '聚会', level: 0, repeat: 'WEEKLY', weekDays: [2, 5], y: d1.y, m: d1.m, d: d1.d, hh: 17, mm: 0, ss: 0 }),
    makeSchedule({ id: 4, title: '医院复诊', content: '带好医保卡与检查单', group: '体检', level: 2, repeat: 'NONE', weekDays: [], y: d3.y, m: d3.m, d: d3.d, hh: 10, mm: 0, ss: 0 }),
    makeSchedule({ id: 5, title: '晚间散步', content: '小区一圈', group: '其他', level: 0, repeat: 'DAILY', weekDays: [], y: d1.y, m: d1.m, d: d1.d, hh: 19, mm: 30, ss: 0 }),
    makeSchedule({ id: 6, title: '子女视频', content: '微信视频通话', group: '聚会', level: 1, repeat: 'WEEKLY', weekDays: [0], y: d1.y, m: d1.m, d: d1.d, hh: 20, mm: 0, ss: 0 }),
    makeSchedule({ id: 7, title: '出行-社区活动', content: '乘坐 987 路', group: '出行', level: 1, repeat: 'NONE', weekDays: [], y: d5.y, m: d5.m, d: d5.d, hh: 9, mm: 0, ss: 0 }),
    makeSchedule({ id: 8, title: '复查化验', content: '空腹，提前到', group: '体检', level: 2, repeat: 'NONE', weekDays: [], y: d8.y, m: d8.m, d: d8.d, hh: 8, mm: 0, ss: 0 }),
  ]
}

/** —— 表单模型 —— */
class FormModel {
  id: number = 0
  title: string = ''
  content: string = ''
  groupIndex: number = 0
  levelIndex: number = 0
  repeatIndex: number = 0
  weekFlags: boolean[] = [false, false, false, false, false, false, false]
  year: number = 1970
  month: number = 1
  day: number = 1
  hour: number = 0
  minute: number = 0
  second: number = 0

  constructor() {
    const n: NowParts = nowParts()
    this.year = n.y; this.month = n.m; this.day = n.d
    this.hour = n.hh; this.minute = n.mm; this.second = n.ss
  }

  fillFrom(s: Schedule): void {
    this.id = s.id
    this.title = s.title
    this.content = s.content
    this.groupIndex = Math.max(0, GROUP_OPTIONS.indexOf(s.group))
    this.levelIndex = Math.min(2, Math.max(0, s.level))
    this.repeatIndex = s.repeat === 'DAILY' ? 1 : (s.repeat === 'WEEKLY' ? 2 : 0)
    const flags: boolean[] = [false, false, false, false, false, false, false]
    for (let i = 0; i < s.weekDays.length; i++) { const k = s.weekDays[i]; if (k >= 0 && k < 7) { flags[k] = true } }
    this.weekFlags = flags
    this.year = s.year; this.month = s.month; this.day = s.day
    this.hour = s.hour; this.minute = s.minute; this.second = s.second
  }

  toSchedule(): Schedule {
    const wd: number[] = []
    for (let i = 0; i < 7; i++) { if (this.weekFlags[i]) { wd.push(i) } }
    const rep: RepeatMode = this.repeatIndex === 1 ? 'DAILY' : (this.repeatIndex === 2 ? 'WEEKLY' : 'NONE')
    return new Sched({
      id: this.id,
      title: this.title.trim(),
      content: this.content.trim(),
      group: GROUP_OPTIONS[this.groupIndex],
      level: this.levelIndex,
      repeat: rep,
      weekDays: rep === 'WEEKLY' ? wd : [],
      y: this.year, m: this.month, d: this.day,
      hh: this.hour, mm: this.minute, ss: this.second
    })
  }
}

/** —— 页面 —— */
@Entry
@Component
struct RichengPage {
  @State private list: Schedule[] = []
  @State private showEditor: boolean = false
  @State private isEditing: boolean = false
  @State private showFilter: boolean = false
  @State private filterIndex: number = 0  // 0=全部，其它=对应 GROUP_OPTIONS

  private form: FormModel = new FormModel()

  aboutToAppear(): void {
    try {
      const arr: Schedule[] = loadAll()
      if (arr.length === 0) {
        const seeded: Schedule[] = seed8()
        this.list = seeded
        saveAll(seeded)
      } else {
        this.list = arr
      }
    } catch {
      this.list = seed8()
      saveAll(this.list)
    }
  }

  /** —— CRUD —— */
  private openCreate(): void {
    this.isEditing = false
    this.form = new FormModel()
    this.form.id = new Date().getTime()
    this.showEditor = true
  }

  private openEdit(s: Schedule): void {
    this.isEditing = true
    const fm: FormModel = new FormModel()
    fm.fillFrom(s)
    this.form = fm
    this.showEditor = true
  }

  private removeById(id: number): void {
    const next: Schedule[] = []
    for (let i = 0; i < this.list.length; i++) {
      if (this.list[i].id !== id) { next.push(this.list[i]) }
    }
    this.list = next
    saveAll(this.list)
    prompt.showToast({ message: '已删除' })
  }

  private submit(): void {
    if (!this.form.title || this.form.title.trim().length === 0) {
      prompt.showToast({ message: '请输入标题' })
      return
    }
    const s: Schedule = this.form.toSchedule()
    const arr: Schedule[] = []
    let replaced: boolean = false
    for (let i = 0; i < this.list.length; i++) {
      const it = this.list[i]
      if (it.id === s.id) { arr.push(s); replaced = true } else { arr.push(it) }
    }
    if (!replaced) { arr.unshift(s) }
    this.list = arr
    saveAll(this.list)
    this.showEditor = false
    prompt.showToast({ message: '已保存' })
  }

  private renderTimeLine(s: Schedule): string {
    const rep: string = s.repeat === 'DAILY'
      ? '每天'
      : (s.repeat === 'WEEKLY'
        ? ((): string => {
        let txt: string = ''
        for (let i = 0; i < s.weekDays.length; i++) {
          const k = s.weekDays[i]
          if (k >= 0 && k < 7) { txt += (txt.length ? '、' : '') + `周${WEEK_TEXT[k]}` }
        }
        return txt.length > 0 ? txt : '每周'
      })()
        : '不重复')
    return `${s.year}-${pad2(s.month)}-${pad2(s.day)} ${pad2(s.hour)}:${pad2(s.minute)}:${pad2(s.second)}  重复：${rep}`
  }

  private filteredList(): Schedule[] {
    if (this.filterIndex <= 0) { return this.list }
    const grp: string = GROUP_OPTIONS[this.filterIndex - 1]
    const out: Schedule[] = []
    for (let i = 0; i < this.list.length; i++) { if (this.list[i].group === grp) { out.push(this.list[i]) } }
    return out
  }

  build() {
    Stack() {
      /** —— 主体 —— */
      Column() {
        // 顶部
        Row() {
          Image($r('app.media.back1')).width(24).height(24).margin({ left: 16 })
            .onClick((): void => { try { router.back() } catch {} })
          Text('日程').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1A1A1A').margin({ left: 12 })
          Blank()
          Button('增加', { type: ButtonType.Capsule }).margin({ right: 16 })
            .onClick((): void => this.openCreate())
        }
        .width('100%').height(56).backgroundColor('#FFFFFF').alignItems(VerticalAlign.Center).margin({ top: -20 })

        // 列表（可滚动）— 不在 UI 树中声明临时 const
        Scroll() {
          Column() {
            if (this.filteredList().length === 0) {
              Text('暂无日程，点右上角“增加”开始创建。').fontColor('#666666').margin({ top: 24 })
            } else {
              ForEach(this.filteredList(), (it: Schedule) => {
                Column() {
                  Row() {
                    Column() {
                      Text(it.title).fontSize(20).fontWeight(FontWeight.Medium)
                      Row() {
                        Text(`分组：${it.group}`).fontSize(14).fontColor('#666666')
                        Text(`  级别：${LEVEL_TEXT[Math.min(2, Math.max(0, it.level))]}`)
                          .fontSize(14).fontColor('#666666').margin({ left: 6 })
                      }.margin({ top: 4 })
                      Text(this.renderTimeLine(it)).fontSize(14).fontColor('#666666').margin({ top: 2 })
                    }
                    Blank()
                    Button('删除', { type: ButtonType.Capsule })
                      .onClick((): void => this.removeById(it.id))
                  }
                  .alignItems(VerticalAlign.Center)

                  if (it.content && it.content.length > 0) {
                    Text(it.content).fontSize(14).fontColor('#1A1A1A').margin({ top: 8 })
                  }
                }
                .width('92%').padding(16).backgroundColor('#FFE4E1').borderRadius(8).margin({ top: 16 })
                .onClick((): void => this.openEdit(it))
              }, (it: Schedule) => it.id.toString())
            }
            Blank().height(24)
          }
          .width('100%').alignItems(HorizontalAlign.Center)
        }
        .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).layoutWeight(1).width('100%')

        // 底部：增加 / 筛选
        Row() {
          Column() {
            Image($r('app.media.add')).width(30).height(30)
            Text('增加日程').fontSize(16).fontColor('#1A1A1A').margin({ top: 4 })
          }.onClick((): void => this.openCreate())

          Column() {
            Image($r('app.media.filter')).width(30).height(30)
            Text('分组筛选').fontSize(16).fontColor('#1A1A1A').margin({ top: 4 })
          }.onClick((): void => { this.showFilter = true })
        }
        .width('100%').padding({ left: 60, right: 60, bottom: 20 }).justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%').height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

      /** —— 编辑弹层 —— */
      if (this.showEditor) {
        // 遮罩
        Column() {}.width('100%').height('100%').backgroundColor('#000000').opacity(0.35)
        .onClick((): void => { this.showEditor = false })
        // 面板
        Scroll() {
          Column() {
            Text(this.isEditing ? '编辑日程' : '新增日程')
              .fontSize(20).fontWeight(FontWeight.Medium).margin({ bottom: 8 })

            // 标题/内容
            TextInput({ placeholder: '标题（必填）', text: this.form.title })
              .width('92%').height(44)
              .onChange((v: string): void => { this.form.title = v })

            TextInput({ placeholder: '内容（可选）', text: this.form.content })
              .width('92%').height(44).margin({ top: 10 })
              .onChange((v: string): void => { this.form.content = v })

            // 分组
            Row() {
              Text('分组').fontSize(16)
              Blank()
              TextPicker({ range: GROUP_OPTIONS })
                .onChange((value: string | string[], _index: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const idx: number = GROUP_OPTIONS.indexOf(v)
                  this.form.groupIndex = idx >= 0 ? idx : 0
                })
            }
            .width('92%').height(48).alignItems(VerticalAlign.Center).margin({ top: 10 })

            // 级别
            Row() {
              Text('级别').fontSize(16)
              Blank()
              TextPicker({ range: LEVEL_TEXT })
                .onChange((value: string | string[], _index: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const idx: number = LEVEL_TEXT.indexOf(v)
                  this.form.levelIndex = idx >= 0 ? idx : 0
                })
            }
            .width('92%').height(48).alignItems(VerticalAlign.Center)

            // 重复
            Row() {
              Text('重复').fontSize(16)
              Blank()
              TextPicker({ range: REPEAT_OPTIONS })
                .onChange((value: string | string[], _index: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const idx: number = REPEAT_OPTIONS.indexOf(v)
                  this.form.repeatIndex = idx >= 0 ? idx : 0
                })
            }
            .width('92%').height(48).alignItems(VerticalAlign.Center)

            // 每周选择（repeat=每周 时显示）— 内联表达式，避免 const on =
            if (this.form.repeatIndex === 2) {
              Row() {
                ForEach(WEEK_TEXT, (lab: string, idx: number) => {
                  Button(`周${lab}`, { type: ButtonType.Capsule })
                    .backgroundColor(this.form.weekFlags[idx] ? '#2E7DFF' : '#F0F0F0')
                    .fontColor(this.form.weekFlags[idx] ? '#FFFFFF' : '#1A1A1A')
                    .margin({ right: 6, top: 6 })
                    .onClick((): void => {
                      const flags: boolean[] = this.form.weekFlags
                      flags[idx] = !flags[idx]
                      this.form.weekFlags = flags.slice()
                    })
                }, (_: string, i: number) => `w${i}`)
              }
              .width('92%').justifyContent(FlexAlign.Start)
            }

            // 日期
            Row() {
              TextPicker({ range: YEAR_OPTS })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const y: number = parseInt(v); if (!isNaN(y)) {
                    this.form.year = y
                    const maxDay: number = new Date(this.form.year, this.form.month, 0).getDate()
                    if (this.form.day > maxDay) { this.form.day = maxDay }
                  }
                })
              Text('年').margin({ left: 4, right: 8 })
              TextPicker({ range: MONTH_OPTS })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const m: number = parseInt(v); if (!isNaN(m)) {
                    this.form.month = m
                    const maxDay: number = new Date(this.form.year, this.form.month, 0).getDate()
                    if (this.form.day > maxDay) { this.form.day = maxDay }
                  }
                })
              Text('月').margin({ left: 4, right: 8 })
              TextPicker({ range: dayOpts(this.form.year, this.form.month) })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const d: number = parseInt(v); if (!isNaN(d)) { this.form.day = d }
                })
              Text('日').margin({ left: 4 })
            }
            .width('92%').height(56).alignItems(VerticalAlign.Center).margin({ top: 10 })

            // 时间
            Row() {
              TextPicker({ range: HOUR_OPTS })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const n: number = parseInt(v); if (!isNaN(n)) { this.form.hour = n }
                })
              Text(':').margin({ left: 4, right: 4 })
              TextPicker({ range: MIN_OPTS })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const n: number = parseInt(v); if (!isNaN(n)) { this.form.minute = n }
                })
              Text(':').margin({ left: 4, right: 4 })
              TextPicker({ range: SEC_OPTS })
                .onChange((value: string | string[], _i: number | number[]): void => {
                  const v: string = Array.isArray(value) ? value[0] : value
                  const n: number = parseInt(v); if (!isNaN(n)) { this.form.second = n }
                })
            }
            .width('92%').height(56).alignItems(VerticalAlign.Center)

            // 操作
            Row() {
              Button('取消', { type: ButtonType.Capsule })
                .onClick((): void => { this.showEditor = false })
              Blank()
              Button('保存', { type: ButtonType.Capsule })
                .onClick((): void => this.submit())
            }
            .width('92%').margin({ top: 14 })
          }
          .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
          .margin({ left: 12, right: 12, bottom: 12 })
        }
        .width('100%').height('100%').align(Alignment.Center)
      }

      /** —— 分组筛选弹层 —— */
      if (this.showFilter) {
        Column() {}.width('100%').height('100%').backgroundColor('#000000').opacity(0.35)
        .onClick((): void => { this.showFilter = false })
        Column() {
          Text('按分组筛选').fontSize(18).fontWeight(FontWeight.Medium).margin({ top: 12, bottom: 8 })
          TextPicker({ range: FILTER_OPTIONS })
            .onChange((value: string | string[], _idx: number | number[]): void => {
              const v: string = Array.isArray(value) ? value[0] : value
              const i: number = FILTER_OPTIONS.indexOf(v)
              this.filterIndex = i >= 0 ? i : 0
            })
          Row() {
            Button('关闭', { type: ButtonType.Capsule })
              .onClick((): void => { this.showFilter = false })
            Blank()
            Button('应用', { type: ButtonType.Capsule })
              .onClick((): void => { this.showFilter = false })
          }
          .width('88%').margin({ top: 12, bottom: 16 })
        }
        .width('86%').backgroundColor('#FFFFFF').borderRadius(16)
        .padding({ left: 16, right: 16, bottom: 8 })
        .align(Alignment.Center)
      }
    } // Stack
    .width('100%').height('100%')
  }
}
