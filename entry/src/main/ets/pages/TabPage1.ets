import { HdsNavDestination, HdsNavDestinationAttribute, ScrollEffectType } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';
import { NAVIGATION_TITLE_BAR_HEIGHT } from '../config/Constants';
import { SampleTaskRepository } from '../model/SampleTaskRepository';
import { SimpleDetailParams } from './secondary/SimpleDetailPage';

@Component
export struct TabPage1 {
  scroller: Scroller = new Scroller();
  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('sample_task_version') taskVersion: number = 0;

  private async appendCrossTabTask(): Promise<void> {
    const repo: SampleTaskRepository = SampleTaskRepository.instance();
    if (!repo.isReady()) {
      await repo.init();
    }
    await repo.appendTab1Task(this.taskVersion);
    this.taskVersion += 1;
  }

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('这些页面展示模板推荐的页面结构、系统图标、滚动配置、状态加载与列表刷新写法。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(24)
        .width('100%')

      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
          .fontSize(26)
          .fontColor([$r('sys.color.brand')])

        Column({ space: 4 }) {
          Text('Scroll 默认配置')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text('隐藏滚动条，开启 Spring 回弹，内容从 TopStart 对齐。')
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

      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.moon_circle_fill'))
          .fontSize(26)
          .fontColor([$r('sys.color.brand')])

        Column({ space: 4 }) {
          Text('深色模式适配')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text('页面使用系统语义色，不给状态栏和背景写死单一颜色。')
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

      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.square_grid_2x2'))
          .fontSize(26)
          .fontColor([$r('sys.color.brand')])

        Column({ space: 4 }) {
          Text('统一布局边距')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text('根 Column 统一控制左右边距，内部模块只处理自身间距。')
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

      Row({ space: 12 }) {
        SymbolGlyph($r('sys.symbol.arrow_2_circlepath'))
          .fontSize(26)
          .fontColor([$r('sys.color.brand')])

        Column({ space: 6 }) {
          Text('跨页面数据同步')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text(`当前同步版本 ${this.taskVersion}。点击后写入 repository，Tab3 通过版本信号自动重载列表。`)
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

      Button('Tab1 写入数据，同步到 Tab3')
        .width('100%')
        .onClick(() => {
          void this.appendCrossTabTask();
        })

      Button('示例详情页（带参数）')
        .width('100%')
        .onClick(() => {
          const param: SimpleDetailParams = {
            title: '路由参数示例',
            body: '一级页通过 NavPathStack.pushPath 传入参数，二级页在 onReady 中读取参数并落到 @State，再由 UI 直接绑定状态显示。'
          };
          this.pageInfos.pushPath({ name: 'SimpleDetailPage', param: param });
        })

      Button('关于页')
        .width('100%')
        .onClick(() => {
          this.pageInfos.pushPath({ name: 'SimpleAboutPage' });
        })
    }
    .padding({ top: NAVIGATION_TITLE_BAR_HEIGHT, left: 16, right: 16, bottom: 24 })
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    HdsNavDestination() {
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
    .background($r('sys.color.background_secondary'))
    .titleBar({
      style: {
        scrollEffectOpts: {
          enableScrollEffect: true,
          scrollEffectType: ScrollEffectType.COMMON_BLUR,
          blurEffectiveStartOffset: LengthMetrics.vp(0),
          blurEffectiveEndOffset: LengthMetrics.vp(20)
        }
      },
      content: {
        title: {
          mainTitle: '规范'
        }
      }
    })
    .hideBackButton(true)
  }
}
