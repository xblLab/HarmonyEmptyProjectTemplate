interface OverviewSummary {
  focusMinutes: number;
  tomatoCount: number;
  breakCount: number;
  updatedAt: string;
}

class SampleOverviewRepository {
  private static repo?: SampleOverviewRepository;
  private ready: boolean = false;

  static instance(): SampleOverviewRepository {
    if (!SampleOverviewRepository.repo) {
      SampleOverviewRepository.repo = new SampleOverviewRepository();
    }
    return SampleOverviewRepository.repo;
  }

  isReady(): boolean {
    return this.ready;
  }

  async init(): Promise<void> {
    this.ready = true;
  }

  async queryOverview(version: number): Promise<OverviewSummary> {
    const seed: number = version + 1;
    return {
      focusMinutes: 25 * seed,
      tomatoCount: 2 + version,
      breakCount: 1 + version,
      updatedAt: `刷新版本 ${version}`
    };
  }
}

@Component
export struct TabPage2 {
  scroller: Scroller = new Scroller();
  private reloadToken: number = 0;

  @StorageLink('sample_overview_version') @Watch('onDataVersionChanged') dataVersion: number = 0;
  @State private focusMinutes: number = 0;
  @State private tomatoCount: number = 0;
  @State private breakCount: number = 0;
  @State private updatedAt: string = '等待加载';

  aboutToAppear(): void {
    void this.loadOverview();
  }

  private onDataVersionChanged(): void {
    void this.loadOverview();
  }

  private async ensureRepo(): Promise<SampleOverviewRepository> {
    const repo: SampleOverviewRepository = SampleOverviewRepository.instance();
    if (!repo.isReady()) {
      await repo.init();
    }
    return repo;
  }

  private async loadOverview(): Promise<void> {
    const token: number = ++this.reloadToken;
    const repo: SampleOverviewRepository = await this.ensureRepo();
    const summary: OverviewSummary = await repo.queryOverview(this.dataVersion);
    if (token !== this.reloadToken) {
      return;
    }
    this.focusMinutes = summary.focusMinutes;
    this.tomatoCount = summary.tomatoCount;
    this.breakCount = summary.breakCount;
    this.updatedAt = summary.updatedAt;
  }

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('页面只维护展示所需的 @State，刷新信号使用 @StorageLink，数据统一从 loadOverview 入口写入。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(24)
        .width('100%')

      Row({ space: 12 }) {
        Column({ space: 6 }) {
          Text('专注')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
          Text(`${this.focusMinutes}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('分钟')
            .fontSize(13)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .layoutWeight(1)
        .padding(14)
        .borderRadius(8)
        .backgroundColor($r('sys.color.background_primary'))
        .alignItems(HorizontalAlign.Start)

        Column({ space: 6 }) {
          Text('番茄')
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
          Text(`${this.tomatoCount}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('个')
            .fontSize(13)
            .fontColor($r('sys.color.font_tertiary'))
        }
        .layoutWeight(1)
        .padding(14)
        .borderRadius(8)
        .backgroundColor($r('sys.color.background_primary'))
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')

      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.arrow_2_circlepath'))
          .fontSize(28)
          .fontColor([$r('app.color.app_theme')])

        Column({ space: 6 }) {
          Text('统一加载入口')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
          Text(`休息 ${this.breakCount} 次，${this.updatedAt}`)
            .fontSize(14)
            .fontColor($r('sys.color.font_secondary'))
            .lineHeight(20)
          Text('异步加载使用 reloadToken，只应用最后一次返回结果。')
            .fontSize(13)
            .fontColor($r('sys.color.font_tertiary'))
            .lineHeight(18)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding(14)
      .borderRadius(8)
      .backgroundColor($r('sys.color.background_primary'))

      Button('发送刷新信号')
        .width('100%')
        .backgroundColor($r('app.color.app_theme'))
        .fontColor($r('app.color.app_theme_on'))
        .onClick(() => {
          this.dataVersion += 1;
        })
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
    .title('状态')
  }
}
