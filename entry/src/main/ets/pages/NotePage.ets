// entry/src/main/ets/pages/notePage.ets
import router from '@ohos.router'

// —— 模型 —— //
interface Note {
  id: number
  content: string
  time: number   // 毫秒时间戳
}

// 仅用于 JSON 解析时的弱校验（不用作对外类型）
interface ParsedNote {
  id?: number
  content?: string
  time?: number
}

// 为 JSON 持久化用的瘦身结构，避免内联类型字面量
interface LeanNote {
  id: number
  content: string
  time: number
}

// 公用补零函数（避免在 fmt 里定义嵌套函数）
function pad2(n: number): string {
  return n < 10 ? `0${n}` : `${n}`
}

const STORE_KEY: string = 'NOTES_V1'

// —— 工具 —— //
function fmt(ts: number): string {
  const d: Date = new Date(ts)
  const y: number = d.getFullYear()
  const m: number = d.getMonth() + 1
  const dd: number = d.getDate()
  const hh: number = d.getHours()
  const mm: number = d.getMinutes()
  return `${y}-${pad2(m)}-${pad2(dd)} ${pad2(hh)}:${pad2(mm)}`
}


// —— 本地存取（显式类型 & 健壮校验）—— //
function loadNotes(): Note[] {
  if (!AppStorage.Has(STORE_KEY)) { return [] }
  const raw: object | string | number | boolean | undefined = AppStorage.Get(STORE_KEY)
  if (typeof raw !== 'string') { return [] }

  let parsed: object
  try {
    parsed = JSON.parse(raw) as object
  } catch {
    return []
  }
  if (!Array.isArray(parsed)) { return [] }

  const src: ParsedNote[] = parsed as ParsedNote[]
  const out: Note[] = []
  for (let i = 0; i < src.length; i++) {
    const it: ParsedNote = src[i]
    if (typeof it.id === 'number' && typeof it.content === 'string' && typeof it.time === 'number') {
      out.push({ id: it.id, content: it.content, time: it.time })
    }
  }
  return out
}

function saveNotes(list: Note[]): void {
  const lean: LeanNote[] = []
  for (let i = 0; i < list.length; i++) {
    const n: Note = list[i]
    const item: LeanNote = { id: n.id, content: n.content, time: n.time }
    lean.push(item)
  }
  AppStorage.SetOrCreate(STORE_KEY, JSON.stringify(lean))
}

// —— 页面 —— //
@Entry
@Component
struct NotePage {
  // 输入框内容（新建或编辑）
  @State private text: string = ''
  // 列表
  @State private notes: Note[] = []
  // 正在编辑的笔记 id（0 代表当前是“新建”）
  @State private editingId: number = 0

  aboutToAppear(): void {
    this.notes = loadNotes()
  }

  // 保存：若 editingId=0 → 新建；否则覆盖同 id
  private doSave(): void {
    const content: string = this.text.trim()
    if (content.length === 0) { return }

    const now: number = Date.now()
    if (this.editingId === 0) {
      const item: Note = { id: now, content: content, time: now }
      const next: Note[] = [item]
      for (let i = 0; i < this.notes.length; i++) { next.push(this.notes[i]) }
      this.notes = next
    } else {
      const next: Note[] = []
      for (let i = 0; i < this.notes.length; i++) {
        const it: Note = this.notes[i]
        if (it.id === this.editingId) {
          next.push({ id: it.id, content: content, time: now })
        } else {
          next.push(it)
        }
      }
      this.notes = next
    }

    saveNotes(this.notes)
    this.text = ''
    this.editingId = 0
  }

  // 载入到输入框进行编辑
  private edit(n: Note): void {
    this.text = n.content
    this.editingId = n.id
  }

  private remove(id: number): void {
    const next: Note[] = []
    for (let i = 0; i < this.notes.length; i++) {
      if (this.notes[i].id !== id) { next.push(this.notes[i]) }
    }
    this.notes = next
    saveNotes(this.notes)
    if (this.editingId === id) {
      this.text = ''
      this.editingId = 0
    }
  }

  private clearAll(): void {
    this.notes = []
    saveNotes(this.notes)
    this.text = ''
    this.editingId = 0
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back1')).width(24).height(24).margin({ left: 16 })
          .onClick((): void => { try { router.back() } catch {} })
        Text('记事本').fontSize(20).fontWeight(FontWeight.Medium).margin({ left: 12 })
          .onClick((): void => { try { router.back() } catch {} })
        Blank()
        // 一键清空
        Button('清空', { type: ButtonType.Capsule })
          .margin({ right: 16 })
          .onClick((): void => this.clearAll())
      }
      .width('100%').height(56).alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF').margin({ top: -20 })

      // 输入区
      Column() {
        TextArea({ placeholder: '随手记点什么…', text: this.text })
          .height(120).width('94%').margin({ top: 12 })
          .onChange((v: string): void => { this.text = v })

        Row() {
          // 保存 / 取消编辑
          Button(this.editingId === 0 ? '保存到列表' : '保存修改', { type: ButtonType.Capsule })
            .onClick((): void => this.doSave())
          Blank()
          Button(this.editingId === 0 ? '清空输入' : '取消编辑', { type: ButtonType.Capsule })
            .onClick((): void => { this.text = ''; this.editingId = 0 })
        }
        .width('94%').margin({ top: 12, bottom: 8 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .padding(12)
      .margin({ left: 12, right: 12, top: 12 })

      // 列表
      Scroll() {
        Column() {
          if (this.notes.length === 0) {
            Text('暂无笔记，先写一条吧～').fontColor('#666666').margin({ top: 18 })
          } else {
            ForEach(this.notes, (n: Note) => {
              // 卡片
              Column() {
                Text(n.content).fontSize(16).fontColor('#1A1A1A')
                  .lineHeight(22).maxLines(6)
                Row() {
                  Text(fmt(n.time)).fontSize(12).fontColor('#8A8A8A')
                  Blank()
                  Button('编辑', { type: ButtonType.Capsule })
                    .onClick((): void => this.edit(n))
                  Button('删除', { type: ButtonType.Capsule })
                    .margin({ left: 8 })
                    .onClick((): void => this.remove(n.id))
                }
                .margin({ top: 10 })
              }
              .width('94%').padding(12)
              .backgroundColor('#F7F7F7')
              .borderRadius(10)
              .margin({ top: 10 })
            }, (n: Note) => n.id.toString())
          }
          Blank().height(18)
        }
        .width('100%').alignItems(HorizontalAlign.Center)
      }
      .scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring).layoutWeight(1).width('100%')
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
