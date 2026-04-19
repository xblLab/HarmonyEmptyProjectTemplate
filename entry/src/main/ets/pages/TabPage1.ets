import { HdsNavDestination, HdsNavDestinationAttribute, ScrollEffectType } from '@kit.UIDesignKit';
import { curves, LengthMetrics } from '@kit.ArkUI';
import { NAVIGATION_TITLE_BAR_HEIGHT } from '../config/Constants';
import { SimpleDetailParams } from './secondary/SimpleDetailPage';

@Component
export struct TabPage1 {
  scroller: Scroller = new Scroller();
  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('Tab 1：点击下方进入二级页')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))

      Button('示例详情页（带参数）')
        .width('100%')
        .onClick(() => {
          const param: SimpleDetailParams = {
            title: '示例详情',
            body: '这里是由一级页传入的说明文字。可在 route_map.json 中注册更多二级页，并用 pageInfos.pushPath 跳转。'
          };
          this.pageInfos.pushPath({ name: 'SimpleDetailPage', param: param });
        })

      Button('关于页')
        .width('100%')
        .onClick(() => {
          this.pageInfos.pushPath({ name: 'SimpleAboutPage' });
        })
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
          mainTitle: 'tab 1'
        }
      }
    })
    .hideBackButton(true)
  }
}
