import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { common } from '@kit.AbilityKit'

/** ==== 数据模型 ==== */
interface HeartRate { avg: number; max: number; series: number[] }
type SleepStageName = '深睡' | '浅睡' | '快速眼动' | '清醒'
interface SleepStage { stage: SleepStageName; minutes: number }
interface SpO2 { latest: number; series: number[]; lowAlert: boolean }
interface Sleep { avgHours: number; avgMinutes: number; stages: SleepStage[]; series: number[] }
interface HealthData { heartRate: HeartRate; spo2: SpO2; sleep: Sleep; updatedAt: string }

/** ==== 默认演示数据（DB 未连时） ==== */
const DEFAULT_DATA: HealthData = {
  heartRate: { avg: 72, max: 124, series: [70,72,75,78,82,88,94,100,96,92,86,80,76,74,72,70,68,72,78,84,90,96,88,80] },
  spo2: { latest: 96, series: [98,98,97,97,96,96,95,96,97,98,97,96], lowAlert: false },
  sleep: {
    avgHours: 6, avgMinutes: 31,
    stages: [{ stage: '深睡', minutes: 120 }, { stage: '浅睡', minutes: 180 }, { stage: '快速眼动', minutes: 50 }, { stage: '清醒', minutes: 20 }],
    series: [0,10,20,30,40,60,80,60,40,20,0,0,0,30,60,70,50,30,10,0,0,0,10,20]
  },
  updatedAt: '演示数据'
}

/** ==== 后端接口占位：把这里替换成你的 DB/HTTP 请求 ==== */
async function fetchHealthDataFromDB(_ctx: common.UIAbilityContext): Promise<HealthData> {
  // TODO: 例如：const res = await http.get<HealthData>(url); return res.data;
  throw new Error('DB not connected')
}

/** ==== 复用小组件 —— 百分比条 ==== */
@Component
struct PercentBar {
  value: number = 0     // 0~100
  heightVp: number = 10
  bgColor: string = '#F0F0F0'
  fgColor: string = '#4D7FFF'

  build() {
    Row() {
      Column()
        .width(`${Math.max(0, Math.min(100, this.value))}%`) // 直接计算
        .height(this.heightVp)
        .backgroundColor(this.fgColor)
        .borderRadius(6)

      Column()
        .layoutWeight(1)
        .height(this.heightVp)
        .backgroundColor(this.bgColor)
        .borderRadius(6)
        .margin({ left: 4 })
    }
    .width('100%')
    .height(this.heightVp)
  }
}

/** ==== 复用小组件 —— 迷你柱形趋势图（高度数组已预计算） ==== */
@Component
struct MiniBars {
  heights: number[] = []
  totalHeightVp: number = 40
  barWidthVp: number = 3
  gapVp: number = 2
  color: string = '#FF4D4D'

  build() {
    Row() {
      ForEach(this.heights, (h: number, i: number) => {
        Column() {
          Column().width(this.barWidthVp).height(h).backgroundColor(this.color).borderRadius(2)
        }
        .width(this.barWidthVp)
        .height(this.totalHeightVp)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
        .margin({ right: this.gapVp })
      }, (h: number, i: number) => `${i}_${h}`)
    }
    .height(this.totalHeightVp)
    .width('100%')
  }
}

/** ==== 主页面 ==== */
@Entry
@Component
struct HealthPage {
  @State data: HealthData = DEFAULT_DATA
  @State loading: boolean = false
  @State lastError: string = ''

  // 预计算可视化数据（避免在 build 中写计算）
  @State heartBars: number[] = []
  @State spo2Bars: number[] = []
  @State sleepBars: number[] = []
  @State sleepTotalMin: number = 0
  private readonly barsHeight: number = 60

  private getCtx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  async aboutToAppear(): Promise<void> {
    await this.reload()
  }

  private normalizeToBars(series: number[], totalHeight: number): number[] {
    if (!series || series.length === 0) { return [] }
    let maxVal = series[0]
    let minVal = series[0]
    for (let i = 1; i < series.length; i++) {
      const v = series[i]
      if (v > maxVal) maxVal = v
      if (v < minVal) minVal = v
    }
    const range = Math.max(1, maxVal - minVal)
    const out: number[] = new Array(series.length)
    for (let i = 0; i < series.length; i++) {
      const h = ((series[i] - minVal) / range) * totalHeight
      out[i] = Math.max(2, Math.floor(h)) // 至少 2vp 可见
    }
    return out
  }

  private calcSleepTotalMin(stages: SleepStage[]): number {
    let sum = 0
    for (let i = 0; i < stages.length; i++) { sum += stages[i].minutes }
    return sum
  }

  private stagePercent(mins: number): number {
    const total = this.sleepTotalMin > 0 ? this.sleepTotalMin : 1
    const pct = Math.round((mins * 100) / total)
    return Math.max(0, Math.min(100, pct))
  }

  private recomputeVisuals(): void {
    this.heartBars = this.normalizeToBars(this.data.heartRate.series, this.barsHeight)
    this.spo2Bars  = this.normalizeToBars(this.data.spo2.series, this.barsHeight - 20)
    this.sleepBars = this.normalizeToBars(this.data.sleep.series, this.barsHeight)
    this.sleepTotalMin = this.calcSleepTotalMin(this.data.sleep.stages)
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.lastError = ''
    try {
      const ctx = this.getCtx()
      const fresh = await fetchHealthDataFromDB(ctx)
      this.data = (fresh && fresh.heartRate && fresh.spo2 && fresh.sleep) ? fresh : DEFAULT_DATA
    } catch (_e) {
      this.data = DEFAULT_DATA
      this.lastError = '使用默认数据展示（数据源未连接）'
      promptAction.showToast({ message: this.lastError })
    } finally {
      this.recomputeVisuals()
      this.loading = false
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back1'))
          .width(24).height(24).margin({ left: 16 })
          .onClick((): void => { try { router.back() } catch (err) { console.error('返回失败:', err) } })
        Text('健康管理')
          .fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1A1A1A').margin({ left: 12 })
        Blank()
        Text(this.loading ? '…' : '刷新')
          .fontSize(16).fontColor('#4080FF').margin({ right: 16 })
          .onClick((): void => { if (!this.loading) { this.reload().then(() => {}).catch(() => {}) } })
      }
      .width('100%').height(56).backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center)
      .margin({ top: -20 })

      // 可滚动内容
      Scroll() {
        Column() {
          /** 心率 */
          Column() {
            Row() {
              Image($r('app.media.1')).width(24).height(24)
              Text('心率检测').fontSize(18).fontWeight(FontWeight.Medium).margin({ left: 8 })
              Blank()
              Text(this.data.updatedAt).fontSize(12).fontColor('#888')
            }
            .width('100%').padding({ left: 16, right: 16, top: 16 })

            Column() {
              Row() {
                Column() {
                  Text('心率').fontSize(16).fontColor('#666666')
                  Row() { Text(`平均: ${this.data.heartRate.avg}`).fontSize(16); Text(' bpm').fontSize(14).fontColor('#666666') }
                  Row() { Text(`最大: ${this.data.heartRate.max}`).fontSize(16); Text(' bpm').fontSize(14).fontColor('#666666') }
                }.alignItems(HorizontalAlign.Start)
              }
              .width('100%').padding(16)

              Row() {
                Image($r('app.media.heart')).width(48).height(48).objectFit(ImageFit.Cover).margin({ right: 12 })
                MiniBars({
                  heights: this.heartBars,
                  totalHeightVp: this.barsHeight,
                  barWidthVp: 3,
                  gapVp: 2,
                  color: '#FF4D4D'
                }).layoutWeight(1)
              }
              .width('100%').padding({ left: 16, right: 16, bottom: 16 })
            }
            .backgroundColor('#FFFFFF').borderRadius(8).margin({ top: 8 })
          }
          .width('92%').backgroundColor('#FFE4E1').borderRadius(16).margin({ top: 16 })

          /** 血氧 */
          Column() {
            Row() {
              Image($r('app.media.2')).width(24).height(24)
              Text(this.data.spo2.lowAlert ? '血氧饱和度低' : '血氧饱和度')
                .fontSize(18).fontWeight(FontWeight.Medium).margin({ left: 8 })
              if (this.data.spo2.lowAlert) { Text('⚠').fontSize(18).margin({ left: 6 }) }
              Blank()
              Text(`${this.data.spo2.latest}%`).fontSize(18).fontWeight(FontWeight.Medium)
            }
            .width('100%').padding({ left: 16, right: 16, top: 16 })

            Column() {
              PercentBar({ value: this.data.spo2.latest, heightVp: 12, bgColor: '#EDEFF5', fgColor: '#4D7FFF' })
                .width('92%').margin({ top: 8 })

              MiniBars({
                heights: this.spo2Bars,
                totalHeightVp: this.barsHeight - 20,
                barWidthVp: 4,
                gapVp: 2,
                color: '#4D7FFF'
              }).width('92%').margin({ top: 8 })

              Image($r('app.media.heart2')).width('100%').height(80).objectFit(ImageFit.Cover).margin({ top: 8, bottom: 8 })
            }
            .padding(16)
          }
          .width('92%').backgroundColor('#EAF1FF').borderRadius(16).margin({ top: 16 })

          /** 睡眠 */
          Column() {
            Row() {
              Image($r('app.media.3')).width(24).height(24)
              Text('睡眠分析').fontSize(18).fontWeight(FontWeight.Medium).margin({ left: 8 })
            }
            .width('100%').padding({ left: 16, right: 16, top: 16 })

            Column() {
              Text('日均睡眠时长').fontSize(16).fontColor('#666666')
              Row() {
                Text(`${this.data.sleep.avgHours}`).fontSize(32).fontWeight(FontWeight.Bold)
                Text('小时').fontSize(16).fontColor('#666666')
                Text(`${this.data.sleep.avgMinutes}`).fontSize(32).fontWeight(FontWeight.Bold).margin({ left: 8 })
                Text('分钟').fontSize(16).fontColor('#666666')
              }
              .margin({ top: 8 })

              // 阶段分布（用预计算的总时长换算百分比）
              Column() {
                ForEach(this.data.sleep.stages, (s: SleepStage, idx: number) => {
                  Row() {
                    Text(s.stage).fontSize(14).fontColor('#666').width(56)
                    PercentBar({
                      value: this.stagePercent(s.minutes),
                      heightVp: 10,
                      bgColor: '#F0F0F0',
                      fgColor: idx % 2 === 0 ? '#47C88A' : '#6E59D9'
                    }).layoutWeight(1).margin({ left: 8, right: 8 })
                    Text(`${s.minutes} 分`).fontSize(14).fontColor('#666').width(64)
                  }
                  .width('100%')
                  .margin({ top: 6 })
                }, (s: SleepStage, i: number) => `${s.stage}_${i}`)
              }
              .margin({ top: 12 })

              MiniBars({
                heights: this.sleepBars,
                totalHeightVp: this.barsHeight,
                barWidthVp: 4,
                gapVp: 1,
                color: '#6E59D9'
              })
                .width('100%')
                .margin({ top: 12 })

              Image($r('app.media.sleep')).width('100%').height(160).objectFit(ImageFit.Cover).margin({ top: 12 })
            }
            .padding(16)
          }
          .width('92%').backgroundColor('#F4EDFF').borderRadius(16).margin({ top: 16, bottom: 24 })
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
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
