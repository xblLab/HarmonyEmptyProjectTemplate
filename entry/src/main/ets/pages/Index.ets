import { HdsNavigation, HdsNavigationAttribute } from '@kit.UIDesignKit';

import { TabPage1 } from './TabPage1';
import { TabPage2 } from './TabPage2';
import { TabPage3 } from './TabPage3';
import { TabPage4 } from './TabPage4';

@Entry
@Component
struct Index {
  @Provide pageInfos: NavPathStack = new NavPathStack();

  @State currentTabIndex: number = 0;

  @Builder
  tabBuilder(title: string, targetIndex: number, symbol: Resource) {
    Column({ space: 4 }) {
      SymbolGlyph(symbol)
        .fontSize(24)
        .fontColor([
          this.currentTabIndex === targetIndex ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary')
        ])
        .scale({
          x: this.currentTabIndex === targetIndex ? 1.08 : 1.0,
          y: this.currentTabIndex === targetIndex ? 1.08 : 1.0
        })
        .animation({
          duration: 200,
          curve: Curve.FastOutSlowIn,
          iterations: 1,
          playMode: PlayMode.Normal
        })

      Text(title)
        .fontSize(this.currentTabIndex === targetIndex ? 16 : 14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTabIndex === targetIndex ? $r('sys.color.font_primary') :
          $r('sys.color.font_tertiary'))
        .animation({
          duration: 200,
          curve: Curve.FastOutSlowIn,
          iterations: 1,
          playMode: PlayMode.Normal
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    HdsNavigation(this.pageInfos) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          TabPage1()
        }
        .tabBar(this.tabBuilder('tab 1', 0, $r('sys.symbol.square_grid_2x2')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        TabContent() {
          TabPage2()
        }
        .tabBar(this.tabBuilder('tab 2', 1, $r('sys.symbol.circle_grid_2x2')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        TabContent() {
          TabPage3()
        }
        .tabBar(this.tabBuilder('tab 3', 2, $r('sys.symbol.ranking_fill')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])

        TabContent() {
          TabPage4()
        }
        .tabBar(this.tabBuilder('tab 4', 3, $r('sys.symbol.person_crop_circle_fill_1')))
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
      .barMode(BarMode.Fixed)
      .onTabBarClick((index: number) => {
        this.currentTabIndex = index;
      })
      .onChange((index: number) => {
        this.currentTabIndex = index;
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}
