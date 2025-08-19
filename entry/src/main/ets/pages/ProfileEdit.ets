import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { Profile, loadProfile, saveProfile } from '../common/PrefStore'

@Entry
@Component
struct ProfileEdit {
  @State private nickname: string = ''
  @State private city: string = ''
  @State private avatarUri: string = ''

  aboutToAppear(): void {
    const p: Profile = loadProfile()
    this.nickname = p.nickname
    this.city = p.city
    this.avatarUri = p.avatarUri
  }

  private persist(): void {
    const p: Profile = {
      nickname: this.nickname.trim().length > 0 ? this.nickname.trim() : '未命名',
      city: this.city.trim(),
      avatarUri: this.avatarUri.trim()
    }
    saveProfile(p)
    promptAction.showToast({ message: '资料已保存' })
  }

  build() {
    Column() {
      // 顶部
      Row() {
        Image($r('app.media.back1')).width(24).height(24).margin({ left: 16 })
          .onClick(() => router.back())
        Text('编辑资料').fontSize(20).fontWeight(FontWeight.Medium).margin({ left: 12 })
        Blank()
      }
      .width('100%').height(56).alignItems(VerticalAlign.Center).backgroundColor('#FFFFFF')
      .margin({ top: -20 })

      // 头像
      Column() {
        if (this.avatarUri.length > 0) {
          Image(this.avatarUri).width(100).height(100).borderRadius(50).objectFit(ImageFit.Cover)
        } else {
          Image($r('app.media.wo')).width(100).height(100).borderRadius(50)
        }
        TextInput({ placeholder: '头像URL（可留空）', text: this.avatarUri })
          .width('88%').height(40).margin({ top: 12 })
          .onChange((v: string): void => { this.avatarUri = v })
      }
      .width('100%').alignItems(HorizontalAlign.Center).margin({ top: 12 })

      // 昵称、城市
      TextInput({ placeholder: '昵称', text: this.nickname })
        .width('88%').height(44).margin({ top: 16 })
        .onChange((v: string): void => { this.nickname = v })

      TextInput({ placeholder: '城市', text: this.city })
        .width('88%').height(44).margin({ top: 12 })
        .onChange((v: string): void => { this.city = v })

      // 操作
      Button('保存')
        .width('88%').height(44).margin({ top: 20 })
        .onClick(() => this.persist())

      Button('返回')
        .width('88%').height(44).margin({ top: 8 })
        .onClick(() => router.back())
    }
    .width('100%').height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}
