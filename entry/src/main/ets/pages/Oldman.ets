import router from '@ohos.router'
import prompt from '@ohos.prompt'

/** —— 与日程管理页一致的模型 —— */
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

interface Pair { s: Schedule, t: number }

const STORE_KEY: string = 'SCHEDULES_V1'
const LEVEL_TEXT: string[] = ['普通', '重要', '紧急']
const WEEK_TEXT: string[] = ['日', '一', '二', '三', '四', '五', '六']

function pad2(n: number): string { return n < 10 ? `0${n}` : `${n}` }

/** 解析本地存储为强类型 Schedule[]（ArkTS：避免 any/unknown） */
function loadAll(): Schedule[] {
  try {
    if (!AppStorage.Has(STORE_KEY)) { return [] }
    const raw: string | number | boolean | object | undefined = AppStorage.Get(STORE_KEY)
    if (typeof raw !== 'string') { return [] }

    const arr: Schedule[] = JSON.parse(raw) as Schedule[]
    if (!Array.isArray(arr)) { return [] }

    const out: Schedule[] = []
    for (let i: number = 0; i < arr.length; i++) {
      const s: Schedule = arr[i]
      if (!s || typeof s.id !== 'number' || typeof s.title !== 'string') { continue }
      out.push({
        id: s.id,
        title: s.title,
        content: typeof (s as Schedule).content === 'string' ? s.content : '',
        group: typeof (s as Schedule).group === 'string' ? s.group : '默认',
        level: typeof (s as Schedule).level === 'number' ? s.level : 0,
        repeat: (s.repeat === 'DAILY' || s.repeat === 'WEEKLY') ? s.repeat : 'NONE',
        weekDays: Array.isArray(s.weekDays)
          ? s.weekDays.filter((n: number): boolean => typeof n === 'number')
          : [],
        year: typeof s.year === 'number' ? s.year : new Date().getFullYear(),
        month: typeof s.month === 'number' ? s.month : (new Date().getMonth() + 1),
        day: typeof s.day === 'number' ? s.day : new Date().getDate(),
        hour: typeof s.hour === 'number' ? s.hour : 9,
        minute: typeof s.minute === 'number' ? s.minute : 0,
        second: typeof s.second === 'number' ? s.second : 0
      })
    }
    return out
  } catch {
    return []
  }
}

/** 顶层工具：构造时间戳（避免嵌套函数） */
function makeTs(y: number, m: number, d: number, hh: number, mm: number, ss: number): number {
  return new Date(y, m - 1, d, hh, mm, ss).getTime()
}

/** 计算某个日程“下一次触发”的时间戳（ms）。不可得时返回 Number.MAX_SAFE_INTEGER */
function nextOccurTs(s: Schedule, base: Date): number {
  const nowMs: number = base.getTime()

  if (s.repeat === 'NONE') {
    const t: number = makeTs(s.year, s.month, s.day, s.hour, s.minute, s.second)
    return t >= nowMs ? t : Number.MAX_SAFE_INTEGER
  }

  if (s.repeat === 'DAILY') {
    const t0: number = makeTs(base.getFullYear(), base.getMonth() + 1, base.getDate(),
      s.hour, s.minute, s.second)
    if (t0 >= nowMs) { return t0 }
    const dt: Date = new Date(base.getFullYear(), base.getMonth() + 1, base.getDate() + 1,
      s.hour, s.minute, s.second)
    return dt.getTime()
  }

  if (!s.weekDays || s.weekDays.length === 0) { return Number.MAX_SAFE_INTEGER }

  for (let add: number = 0; add < 14; add++) {
    const d: Date = new Date(base.getFullYear(), base.getMonth(), base.getDate() + add)
    const w: number = d.getDay()
    let hit: boolean = false
    for (let i: number = 0; i < s.weekDays.length; i++) {
      if (s.weekDays[i] === w) { hit = true; break }
    }
    if (!hit) { continue }
    const t: number = makeTs(d.getFullYear(), d.getMonth() + 1, d.getDate(),
      s.hour, s.minute, s.second)
    if (t >= nowMs) { return t }
  }
  return Number.MAX_SAFE_INTEGER
}


/** 将下一次触发时间转为展示文字 */
function friendlyTime(ts: number): string {
  if (ts === Number.MAX_SAFE_INTEGER) { return '—' }
  const d: Date = new Date(ts)
  const w: string = WEEK_TEXT[d.getDay()]
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())} 周${w} ${pad2(d.getHours())}:${pad2(d.getMinutes())}:${pad2(d.getSeconds())}`
}

@Entry
@Component
struct Index {
  // 温馨提醒用的数据（按“最近将到来”的顺序取前 3 条）
  @State private tips: Schedule[] = []
  // 驱动 3s 刷新用的 tick
  @State private tick: number = 0
  // interval 句柄
  @State private timerId: number = 0

  aboutToAppear(): void {
    this.refreshTips()
    this.timerId = setInterval((): void => {
      this.tick = this.tick + 1
      this.refreshTips()
    }, 3000)
  }

  aboutToDisappear(): void {
    if (this.timerId !== 0) {
      clearInterval(this.timerId)
      this.timerId = 0
    }
  }


/** 重新读取本地并计算“最近将到来”的前三条 */

  private refreshTips(): void {
    const all: Schedule[] = loadAll()
    if (all.length === 0) { this.tips = []; return }

    const now: Date = new Date()
    const pairs: Pair[] = []
    for (let i: number = 0; i < all.length; i++) {
      const s: Schedule = all[i]
      const t: number = nextOccurTs(s, now)
      if (t !== Number.MAX_SAFE_INTEGER) { pairs.push({ s: s, t: t }) }
    }
    pairs.sort((a: Pair, b: Pair): number => a.t - b.t)

    //取第一条
    // this.tips = pairs.length > 0 ? [pairs[0].s] : []

    // 取前 2 条
    const TAKE: number = 2
    const result: Schedule[] = []
    for (let i: number = 0; i < pairs.length && i < TAKE; i++) {
      result.push(pairs[i].s)
    }
    this.tips = result

    //取前3条
    // const take: Schedule[] = []
    // for (let i: number = 0; i < pairs.length && i < 3; i++) { take.push(pairs[i].s) }
    // this.tips = take
  }

  private renderTimeLine(s: Schedule): string {
    const weekText: string[] = ['日', '一', '二', '三', '四', '五', '六'];
    const pad2 = (n: number): string => (n < 10 ? `0${n}` : `${n}`);

    let rep: string;
    if (s.repeat === 'DAILY') {
      rep = '每天';
    } else if (s.repeat === 'WEEKLY') {
      if (Array.isArray(s.weekDays) && s.weekDays.length > 0) {
        let txt = '';
        for (let i = 0; i < s.weekDays.length; i++) {
          const k = s.weekDays[i];
          if (k >= 0 && k < 7) { txt += (txt ? ' ' : '') + `周${weekText[k]}`; }
        }
        rep = txt || '每周';
      } else {
        rep = '每周';
      }
    } else {
      rep = '不重复';
    }

    return `${s.year}-${pad2(s.month)}-${pad2(s.day)} ${pad2(s.hour)}:${pad2(s.minute)}:${pad2(s.second)}  重复：${rep}`;
  }


  private toSchedules(): void {
    try { router.pushUrl({ url: 'pages/richengPage' }) } catch { }
  }

  /** 友好时间：把时间戳格式成 “MM-DD HH:mm” */
  private friendlyTime(ts: number): string {
    if (ts === Number.MAX_SAFE_INTEGER) { return '—' }
    const d: Date = new Date(ts)
    const pad = (n: number): string => (n < 10 ? `0${n}` : `${n}`)
    return `${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
  }

  /** 供 UI 直接用：给某条日程生成“下次时间：xxxx”这一整行文案 */
  private nextTimeLine(s: Schedule): string {
    const ts: number = nextOccurTs(s, new Date())
    return `下次时间：${this.friendlyTime(ts)}`
  }

  build() {
    Column() {
      // —— 上半：温馨提醒（无 Scroll）——
      Column() {
        Row() {
          Text('温馨提醒')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
          Blank()
          Button('去管理', { type: ButtonType.Capsule })
            .onClick((): void => this.toSchedules())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })

        // —— 最近一条提示 —— //
        // if (this.tips.length === 0) {
        //   Text('暂无即将到来的日程')
        //     .fontSize(16)
        //     .fontColor('#666666')
        // } else {
        //   Column() {
        //     // 标题
        //     Text(this.tips[0].title)
        //       .fontSize(20)
        //       .fontWeight(FontWeight.Medium)
        //
        //     // 时间行
        //     Text(this.renderTimeLine(this.tips[0]))
        //       .fontSize(14)
        //       .fontColor('#666666')
        //       .margin({ top: 4 })
        //
        //     // 可选内容
        //     if ((this.tips[0].content ?? '').length > 0) {
        //       Text(this.tips[0].content as string)
        //         .fontSize(14)
        //         .fontColor('#1A1A1A')
        //         .margin({ top: 4 })
        //     }
        //   }
        //   .padding(12)
        //   .backgroundColor('#FFF5E6')
        //   .borderRadius(8)
        //   .margin({ top: 10 })
        // }

        // —— 最近两条提示 —— //
        if (this.tips.length === 0) {
          Text('暂无即将到来的日程')
            .fontSize(16)
            .fontColor('#666666')
        } else {
          Column() {
            ForEach(this.tips.slice(0, 2), (it: Schedule, idx: number) => {
              Column() {
                // 标题
                Text(it.title)
                  .fontSize(20)
                  .fontWeight(FontWeight.Medium)

                // 时间行
                Text(this.renderTimeLine(it))
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ top: 4 })

                // 可选内容
                if ((it.content ?? '').length > 0) {
                  Text(it.content as string)
                    .fontSize(14)
                    .fontColor('#1A1A1A')
                    .margin({ top: 4 })
                }
              }
              .padding(12)
              .backgroundColor('#FFF5E6')
              .borderRadius(8)
              .margin({ top: idx === 0 ? 10 : 6 }) // 第一条和第二条间隔不同
            }, (it: Schedule) => it.id.toString())
          }
        }


        // if (this.tips.length === 0) {
        //   Text('暂无即将到来的日程，点击“去管理”添加吧。')
        //     .fontColor('#666666')
        //     .fontSize(14)
        //     .margin({ left: 16, right: 16, top: 8, bottom: 12 })
        // } else {
        //   // 展示最多 3 个卡片
        //   ForEach(this.tips, (it: Schedule) => {
        //     Text(this.nextTimeLine(it))
        //       .fontSize(13)
        //       .fontColor('#666666')
        //       .margin({ top: 6 })
        //     Column() {
        //       Row() {
        //         // 标题 + 分组/级别
        //         Column() {
        //           Text(it.title).fontSize(18).fontWeight(FontWeight.Medium)
        //           Row() {
        //             Text(`分组：${it.group}`).fontSize(13).fontColor('#666666')
        //             Text(`  级别：${LEVEL_TEXT[Math.min(2, Math.max(0, it.level))]}`)
        //               .fontSize(13).fontColor('#666666').margin({ left: 6 })
        //           }.margin({ top: 4 })
        //         }
        //         Blank()
        //         // 查看按钮
        //         Button('查看', { type: ButtonType.Capsule })
        //           .onClick((): void => this.toSchedules())
        //       }
        //       .alignItems(VerticalAlign.Center)
        //
        //       // 时间行
        //       Text(this.nextTimeLine(it))
        //         .fontSize(13)
        //         .fontColor('#666666')
        //         .margin({ top: 6 })
        //
        //       // 备注
        //       if (it.content && it.content.length > 0) {
        //         Text(it.content).fontSize(14).fontColor('#1A1A1A').margin({ top: 8 })
        //       }
        //     }
        //     .width('92%')
        //     .padding(16)
        //     .backgroundColor('#FFE4E1')
        //     .borderRadius(10)
        //     .margin({ top: 10 })
        //     .onClick((): void => this.toSchedules())
        //   }, (it: Schedule) => `${it.id}`)
        // }
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .alignItems(HorizontalAlign.Center)

      // —— 下半：原有功能按钮，全部保留 —— //
      Column() {
        // 乘车二维码
        Button() {
          Row() {
            Image($r('app.media.bus')).width(30).height(30)
            Text('打开备忘录').fontSize(20)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({ left: 15 })
          }
          .width('100%').padding({ left: 20 }).alignItems(VerticalAlign.Center)
        }
        .width('95%').height(60).margin({ top: 10 })
        .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
        .borderRadius(10)
        .onClick((): void => {
          try { router.pushUrl({ url: 'pages/NotePage' }) } catch (err) { console.error('跳转失败:', err) }
        })

        // 紧急呼叫
        Button() {
          Row() {
            Image($r('app.media.call')).width(30).height(30)
            Text('紧急呼叫').fontSize(20)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({ left: 15 })
          }
          .width('100%').padding({ left: 20 }).alignItems(VerticalAlign.Center)
        }
        .width('95%').height(60).margin({ top: 10 })
        .backgroundColor($r('sys.color.ohos_id_color_warning'))
        .borderRadius(10)
        .onClick((): void => {
          try { router.pushUrl({ url: 'pages/callPage' }) } catch (err) { console.error('跳转失败:', err) }
        })

        // 导航 & 手电筒
        Row() {
          Button() {
            Column() {
              Image($r('app.media.daohang')).width(30).height(30)
              Text('导航').fontSize(20)
                .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
            }.alignItems(HorizontalAlign.Center)
          }
          .width('46%').height(70)
          .backgroundColor('#ff8be98f') // 清新的浅绿色
          .borderRadius(10)
          .onClick((): void => {
            try { router.pushUrl({ url: 'pages/daohangPage' }) } catch (err) { console.error('跳转失败:', err) }
          })

          Button() {
            Column() {
              Image($r('app.media.camera')).width(30).height(30)
              Text('手电筒').fontSize(20)
                .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
            }.alignItems(HorizontalAlign.Center)
          }
          .width('46%').height(70)
          .backgroundColor('#FFC107') // 明亮的琥珀黄
          .borderRadius(10)
          .onClick(() => {
            try {
              router.pushUrl({ url: 'pages/torchPage' })
            } catch (err) {
              console.error('跳转失败:', err)
            }
          })
        }
        .width('95%').margin({ top: 10 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 喝水助手 & 日程
        Row() {
          Button() {
            Column() {
              Image($r('app.media.community')).width(30).height(30)
              Text('喝水助手').fontSize(20)
                .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
            }.alignItems(HorizontalAlign.Center)
          }
          .width('46%').height(70)
          .backgroundColor('#2196F3') // 清新的水蓝色
          .borderRadius(10)
          .onClick((): void => {
            try { router.pushUrl({ url: 'pages/Drink' }) } catch (err) { console.error('跳转失败:', err) }
          })

          Button() {
            Column() {
              Image($r('app.media.calendar')).width(30).height(30)
              Text('日程').fontSize(20)
                .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
            }.alignItems(HorizontalAlign.Center)
          }
          .width('46%').height(70)
          .backgroundColor('#ffc739e0') // 优雅的紫罗兰色
          .borderRadius(10)
          .onClick((): void => {
            try { router.pushUrl({ url: 'pages/richengPage' }) } catch (err) { console.error('跳转失败:', err) }
          })
        }
        .width('95%').margin({ top: 10 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 健康管理
        Button() {
          Row() {
            Image($r('app.media.health')).width(30).height(30)
            Text('健康管理').fontSize(20)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .margin({ left: 15 })
          }
          .width('100%').padding({ left: 20 }).alignItems(VerticalAlign.Center)
        }
        .width('95%').height(60).margin({ top: 10, bottom: 8 })
        .backgroundColor('#c1a6dce3')
        .borderRadius(10)
        .onClick((): void => {
          try { router.pushUrl({ url: 'pages/healthPage' }) } catch (err) { console.error('跳转失败:', err) }
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)

      // —— 底部导航栏（保持不变） —— //
      Row() {
        Column() {
          Image($r('app.media.home1')).width(25).height(25)
          Text('首页').fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
        }

        Button() {
          Image($r('app.media.gongyi')).width(50).height(50)
        }
        .width(60).height(60)
        .backgroundColor('#fff5d1d1')
        .borderRadius(30)

        Column() {
          Image($r('app.media.user1')).width(25).height(25)
          Text('我的').fontSize(14)
            .fontColor($r('sys.color.ohos_id_color_text_primary')).margin({ top: 5 })
        }
        .onClick((): void => {
          try {
            router.replaceUrl({ url: 'pages/MinePage', params: { from: 'index' } })
          } catch (err) {
            console.error('跳转失败:', err)
          }
        })
      }
      .width('100%').height(70)
      .backgroundColor($r('sys.color.ohos_id_color_background'))
      .justifyContent(FlexAlign.SpaceEvenly)
      .alignItems(VerticalAlign.Center)
      .position({ y: '100%' }).translate({ y: -70 })
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
