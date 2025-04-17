import { BusinessError } from '@kit.BasicServicesKit';
import { UIContext } from "@ohos.arkui.UIContext";
import { router } from '@kit.ArkUI';


@Entry
@Component
export default struct Index {
  @StorageProp('_UIContext') _UIContext: UIContext | null = null;
  @State message: string = 'Hello World';

  pushfirst = () => {
    router.pushUrl({url:'pages/first'}, router.RouterMode.Standard, (err) => {
    if (err) {
      console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
      return;
    }
    console.info('Invoke pushUrl succeeded.')}
  )
  this.message = 'first page';
  }

  pushsecond = () => {
    router.pushUrl({url:'pages/second'}, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke pushUrl succeeded.')}
    )
    this.message = 'second page';
  }

  pushthird = () => {
    router.pushUrl({url:'pages/third'}, router.RouterMode.Standard, (err) => {
      if (err) {
        console.error(`Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      console.info('Invoke pushUrl succeeded.')}
    )
    this.message = 'third page';
  }

  build() {
    Column() {
          Swiper() {
            Image($r('app.media.101'))
              .width("360vp")
              .height("222.23vp")
              .borderRadius("20vp")
              .opacity(0.93)
              .shadow({ offsetX: 0, offsetY: 0, radius: 0, color: "#a5a1a1" })
              .syncLoad(true)
              .objectFit(ImageFit.Cover)
            Image($r('app.media.102'))
              .width("318.06vp")
              .height("193.75vp")
              .constraintSize({ minHeight: "10vp", maxHeight: "0vp" })
              .borderRadius("20vp")
              .opacity(0.95)
              .shadow({ offsetX: 0, offsetY: 10, radius: 0, color: "grey" })
              .syncLoad(false)
              .objectFit(ImageFit.Cover)
            Image($r('app.media.103'))
              .width("320.14vp")
              .height("191.67vp")
              .borderRadius("20vp")
              .syncLoad(false)
              .objectFit(ImageFit.Cover)
          }
          .width('90%')
          .height('20%')
          //.margin({left:50,right:50})
          .opacity(0.95)
          Row() {
            Text("120急救")
              .position({ x: "12vp", y: "90vp" })
              .fontColor(Color.Black)
            Image($r('app.media.104'))
              .width("70vp")
              .height("70vp")
              .position({ x: "5vp", y: "5vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Cover)
            Text("挂号")
              .position({ x: "115vp", y: "90vp" })
              .fontColor(Color.Black)
            Image($r('app.media.105'))
              .width("60vp")
              .height("60vp")
              .position({ x: "95vp", y: "10vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
            Text("用药提醒")
              .position({ x: "183vp", y: "90vp" })
              .fontColor(Color.Black)
            Image($r('app.media.106'))
              .width("60vp")
              .height("60vp")
              .position({ x: "180vp", y: "10vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
            Text("护工预约")
              .position({ x: "267vp", y: "90vp" })
              .fontColor(Color.Black)
            Image($r('app.media.107'))
              .width("60vp")
              .height("60vp")
              .position({ x: "265vp", y: "10vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
          }       //120
          .width("100%")
          .height("30%")
          .position({ x: "10vp", y: "165vp" })
          Row() {
            Text("AI智能问诊")
              .width("100vp")
              .height("30vp")
              .position({ x: "15vp", y: "10vp" })
              .borderWidth("0vp")
             // .opacity(0.99)
              .fontColor("#050505")
              .shadow({ offsetX: 0, offsetY: 0, radius: 0, color: "#050505" })
              .fontSize("19fp")
            Text("AI将为您推荐合适的就医科室")
              .position({ x: "13vp", y: "95vp" })
              .fontColor(Color.Black)
              .fontSize("14fp")
            TextInput({ text: "请输入症状关键词" })
              .width("310vp")
              .height("40vp")
              .position({ x: "15vp", y: "45vp" })
              .borderColor("#2d2a2a")
              .borderRadius("5vp")
              .opacity(0.52)
              .shadow({ offsetX: 0, offsetY: 0, radius: 0, color: "#e3e3e3" })
            Image($r('app.media.108'))
              .width("30vp")
              .height("30vp")
              .position({ x: "310vp", y: "10vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
          }     //ai智能问诊
          .width("100%")
          .height("30%")
          .position({ x: "10vp", y: "330vp" })
          .borderWidth("2vp")
          .borderColor("#ffffffff")
          .borderRadius("10vp")
          .opacity(0.4)
          .shadow({ offsetX: 0, offsetY: 0, radius: 0, color: "#ff000000" })
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          Row() {
            Text("紧急联系人")
              .width("100.71vp")
              .height("39.32vp")
              .position({ x: "10vp", y: "0" })
              .fontColor("#ff000000")
              .fontSize("18fp")
            Image('app.media.114')
              .width("40vp")
              .height("40vp")
              .position({ x: "10vp", y: "85vp" })
              .syncLoad(true)
              .objectFit(ImageFit.Contain)
            Image('app.media.114')
              .width("40vp")
              .height("40vp")
              .position({ x: "10vp", y: "40vp" })
              .syncLoad(true)
              .objectFit(ImageFit.Contain)
            Text("李护士")
              .width("150vp")
              .height("40vp")
              .position({ x: "60vp", y: "85vp" })
              .fontColor(Color.Black)
            Text("张医生")
              .width("150vp")
              .height("40vp")
              .position({ x: "60vp", y: "40vp" })
              .fontColor(Color.Black)
              .shadow({ offsetX: 0, offsetY: 0, radius: 0, color: "#0d0c0c" })
            Image($r('app.media.112'))
              .width("40vp")
              .height("40vp")
              .position({ x: "290vp", y: "85vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Cover)
            Image('app.media.112')
              .width("40vp")
              .height("40vp")
              .position({ x: "10vp", y: "130vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
            Text("志愿者王阿姨")
              .width("150vp")
              .height("40vp")
              .position({ x: "60vp", y: "130vp" })
              .fontColor(Color.Black)
            Image('app.media.112')
              .width("40vp")
              .height("40vp")
              .offset({ x: "290vp", y: "57vp" })
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
            Image('app.media.114')
              .width("40vp")
              .height("40vp")
              .position({ x: "290vp", y: "40vp" })
              .borderColor("#f7f7f7")
              .syncLoad(false)
              .objectFit(ImageFit.Contain)
          }//紧急联系人
          .width("100%")
          .height("40%")
          .position({ x: "10vp", y: "465vp" })
          .borderWidth("2vp")
          .borderColor("#f5f8f9")
          .borderRadius("10vp")
          .opacity(0.4)
      }
    .width("100%")
    .height("100%")
  }

}