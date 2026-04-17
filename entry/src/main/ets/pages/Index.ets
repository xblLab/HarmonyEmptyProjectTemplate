import { common } from '@kit.AbilityKit';
import { display, window } from '@kit.ArkUI';

function pxToVp(px: number): number {
  const d = display.getDefaultDisplaySync();
  return px * 160 / d.densityDPI;
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State padTop: number = 0;
  @State padBottom: number = 0;

  aboutToAppear(): void {
    this.refreshSystemAvoidPadding();
  }

  onPageShow(): void {
    this.refreshSystemAvoidPadding();
  }

  private refreshSystemAvoidPadding(): void {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    window.getLastWindow(ctx).then((win: window.Window) => {
      const avoid = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      this.padTop = pxToVp(avoid.topRect.height);
      this.padBottom = pxToVp(avoid.bottomRect.height);
    });
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Orange)
    .padding({ top: this.padTop, bottom: this.padBottom })
  }
}
