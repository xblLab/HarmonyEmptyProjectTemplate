@Builder
export function SimpleAboutPageBuilder() {
  SimpleAboutPage();
}

@Component
struct SimpleAboutPage {
  build() {
    NavDestination() {
      Column({ space: 12 }) {
        Text('这是模板里的示例二级页，通过 NavPathStack 从一级 Tab 推入。')
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(24)
        Text('版本 1.0.0')
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('关于')
    .onBackPressed(() => {
      return false;
    });
  }
}
