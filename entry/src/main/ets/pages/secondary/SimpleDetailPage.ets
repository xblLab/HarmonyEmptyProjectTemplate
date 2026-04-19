export interface SimpleDetailParams {
  title: string;
  body: string;
}

@Builder
export function SimpleDetailPageBuilder() {
  SimpleDetailPage();
}

@Component
struct SimpleDetailPage {
  @State pageTitle: string = '详情';
  @State body: string = '';

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Text(this.body)
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .lineHeight(24)
          .width('100%')
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title(this.pageTitle)
    .onReady((context: NavDestinationContext) => {
      const p = context.pathInfo.param as SimpleDetailParams;
      if (p) {
        this.pageTitle = p.title.length > 0 ? p.title : '详情';
        this.body = p.body;
      }
    })
    .onBackPressed(() => {
      return false;
    });
  }
}
