interface LayoutRule {
  title: string;
  detail: string;
  symbol: Resource;
}

@Component
export struct TabPage4 {
  scroller: Scroller = new Scroller();
  private rules: LayoutRule[] = [
    {
      title: '根容器控制左右边距',
      detail: '子模块只设置自身 padding、margin 与背景，不重复写页面级左右边距。',
      symbol: $r('sys.symbol.square_2_below_rectangle')
    },
    {
      title: '使用系统语义色',
      detail: '背景、文字和强调色跟随深浅色模式，避免固定状态栏颜色。',
      symbol: $r('sys.symbol.moon_fill')
    },
    {
      title: '系统 Symbol 图标',
      detail: '需要图标时使用 symbolname.cursorrules 中的资源，不用字符或 emoji 替代。',
      symbol: $r('sys.symbol.doc_text_badge_clock')
    }
  ];

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('当前页面的左右边距只在根 Column 设置；页面背景、卡片背景和文字颜色都使用系统语义色。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(24)
        .width('100%')

      ForEach(this.rules, (rule: LayoutRule) => {
        Row({ space: 12 }) {
          SymbolGlyph(rule.symbol)
            .fontSize(28)
            .fontColor([$r('app.color.app_theme')])

          Column({ space: 5 }) {
            Text(rule.title)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))

            Text(rule.detail)
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .lineHeight(20)
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding(14)
        .borderRadius(8)
        .backgroundColor($r('sys.color.background_primary'))
      }, (rule: LayoutRule) => rule.title)
    }
    .padding({ left: 16, right: 16, bottom: 24 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        this.buildContentView()
      }
      .align(Alignment.TopStart)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .friction(0.8)
      .height('100%')
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('布局')
  }
}
