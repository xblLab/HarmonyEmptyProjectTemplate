import { HdsNavDestination, HdsNavDestinationAttribute, ScrollEffectType } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';
import { NAVIGATION_TITLE_BAR_HEIGHT } from '../config/Constants';

@Component
export struct TabPage2 {
  scroller: Scroller = new Scroller();

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('Tab 2 content')
        .fontSize(16)
    }
    .padding({ top: NAVIGATION_TITLE_BAR_HEIGHT, left: 16, right: 16 })
    .width('100%')
    .height('100%')
  }

  build() {
    HdsNavDestination() {
      Scroll(this.scroller) {
        this.buildContentView()
      }
      .align(Alignment.Top)
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
          mainTitle: 'tab 2'
        }
      }
    })
    .hideBackButton(true)
  }
}
