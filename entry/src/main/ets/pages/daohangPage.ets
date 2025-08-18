import router from '@ohos.router'
import { common } from '@kit.AbilityKit'
import { geoLocationManager } from '@kit.LocationKit'
import promptAction from '@ohos.promptAction'
import deviceInfo from '@ohos.deviceInfo'
import { MapComponent, mapCommon, map } from '@kit.MapKit'
import Want from '@ohos.app.ability.Want'
import { BusinessError } from '@kit.BasicServicesKit'

type NavMode = 'drive' | 'walk' | 'transit'

@Entry
@Component
struct DaohangPage {
  @State destText: string = '上海杉达学院（金海）'
  @State mode: NavMode = 'walk'
  @State locating: boolean = false

  private mapCtl?: map.MapComponentController

  // 默认相机（杉达金海）
  private readonly defaultCamera: mapCommon.CameraPosition = {
    target: { latitude: 31.32194, longitude: 121.60070 },
    zoom: 16,
    tilt: 0,
    bearing: 0
  }

  // 注意：此版本 MapOptions 不支持 camera/cameraPosition，只放手势/控件字段
  private readonly mapOpts: mapCommon.MapOptions = {
    position: this.defaultCamera,
    zoomGesturesEnabled: true,
    scrollGesturesEnabled: true,
    rotateGesturesEnabled: true,
    tiltGesturesEnabled: true,
    zoomControlsEnabled: true
  }

  private getCtx(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext
  }

  // 地图就绪：先移到默认相机，再尝试定位到“我的位置”
  private async onMapReady(ctrl: map.MapComponentController): Promise<void> {
    this.mapCtl = ctrl

    // 先设默认相机
    this.mapCtl.moveCamera(this.defaultCamera)

    // 再尝试当前位置
    try {
      this.locating = true
      const loc = await geoLocationManager.getCurrentLocation()
      this.locating = false
      if (loc && this.mapCtl) {
        const cam: mapCommon.CameraPosition = {
          target: { latitude: loc.latitude, longitude: loc.longitude },
          zoom: 16, tilt: 0, bearing: 0
        }
        this.mapCtl.moveCamera(cam)
      }
    } catch (e) {
      this.locating = false
      console.warn('[DaohangPage] getCurrentLocation failed:', e)
    }
  }

  private setMode(m: NavMode): void { this.mode = m }

  // 外部导航（Petal Maps → geo 兜底）
  private async startExternalNavigation(dest: string): Promise<void> {
    const d = encodeURIComponent(dest)
    const mode = this.mode === 'walk' ? 'walk' : (this.mode === 'transit' ? 'transit' : 'drive')
    const petalUri = `petalmaps://routePlan?daddr=${d}&mode=${mode}`
    const geoUri = `geo:0,0?q=${d}`

    const ctx = this.getCtx()
    try {
      const want1: Want = { uri: petalUri }
      await ctx.startAbility(want1)
      return
    } catch (e1) {
      console.warn('[DaohangPage] petalmaps failed, fallback to geo:', e1)
    }
    const want2: Want = { uri: geoUri }
    await ctx.startAbility(want2)
  }

  private async onNavigate(): Promise<void> {
    const dest = this.destText.trim()
    if (!dest) { promptAction.showToast({ message: '请输入目的地' }); return }
    if (deviceInfo.deviceType !== 'phone' && deviceInfo.deviceType !== '2in1') {
      promptAction.showToast({ message: '模拟器可能不支持地图/定位，请真机测试' })
    }
    await this.startExternalNavigation(dest)
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Image($r('app.media.back1')).width(24).height(24).margin({ left: 16 })
          .onClick(() => { try { router.back() } catch (e) { console.error('返回失败', e) } })
        Text('导航').fontSize(20).fontWeight(FontWeight.Medium).fontColor('#1A1A1A').margin({ left: 12 })
      }
      .width('100%').height(56).backgroundColor('#FFFFFF')
      .alignItems(VerticalAlign.Center).margin({ top: -20 })

      // 目的地输入
      Column() {
        Row() {
          Image($r('app.media.start')).width(24).height(24)
          Text(this.locating ? '正在获取我的位置…' : '我的位置')
            .fontSize(16).fontColor('#1A1A1A').margin({ left: 8 })
        }.width('100%').padding(16)

        Row() {
          Image($r('app.media.end')).width(24).height(24)
          TextInput({ text: this.destText, placeholder: '输入目的地' })
            .width('80%').height(36).margin({ left: 8 })
            .onChange((v: string): void => { this.destText = v })
        }.width('100%').padding(16)

        Button('导航')
          .width('90%').height(45).fontSize(18).fontColor('#FFFFFF')
          .backgroundColor($r('sys.color.ohos_id_color_connected'))
          .margin({ top: 16, bottom: 16 }).borderRadius(22)
          .onClick((): void => { this.onNavigate().then(() => {}).catch(() => {}) })
      }
      .width('95%').margin({ top: 16 }).backgroundColor('#FFFFFF').borderRadius(8)

      // 内嵌地图：用 mapCallback(err, ctl) 形式
      MapComponent({
        mapOptions: this.mapOpts,
        mapCallback: (err: BusinessError, ctl: map.MapComponentController): void => {
          if (err) {
            console.error('[DaohangPage] map init error:', JSON.stringify(err))
            return
          }
          this.onMapReady(ctl).then(() => {}).catch(() => {})
        }
      })
        .width('100%')
        .layoutWeight(1)

      // 底部模式切换
      Row() {
        Button('步行')
          .width('33%').height(45).fontSize(16)
          .fontColor(this.mode === 'walk' ? '#4080FF' : '#1A1A1A')
          .backgroundColor('#FFFFFF')
          .onClick((): void => this.setMode('walk'))

        Button('打车')
          .width('33%').height(45).fontSize(16)
          .fontColor(this.mode === 'drive' ? '#4080FF' : '#1A1A1A')
          .backgroundColor('#FFFFFF')
          .onClick((): void => this.setMode('drive'))

        Button('公交地铁')
          .width('33%').height(45).fontSize(16)
          .fontColor(this.mode === 'transit' ? '#4080FF' : '#1A1A1A')
          .backgroundColor('#FFFFFF')
          .onClick((): void => this.setMode('transit'))
      }
      .width('100%').padding(8).backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceEvenly)
      .position({ y: '100%' }).translate({ y: -53 })
    }
    .width('100%').height('100%')
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
