import { HdsNavDestination, HdsNavDestinationAttribute, ScrollEffectType } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';
import { NAVIGATION_TITLE_BAR_HEIGHT } from '../config/Constants';

interface SampleTask {
  id: number;
  title: string;
  owner: string;
  done: boolean;
  updatedAt: number;
}

@Component
export struct TabPage3 {
  scroller: Scroller = new Scroller();
  @State private tasks: SampleTask[] = [
    { id: 1, title: '根 Column 统一 padding', owner: '布局', done: true, updatedAt: 1 },
    { id: 2, title: 'Scroll 使用 Spring 回弹', owner: '滚动', done: true, updatedAt: 1 },
    { id: 3, title: 'ForEach key 拼接 updatedAt', owner: '刷新', done: false, updatedAt: 1 },
    { id: 4, title: '图标来自 symbolname', owner: '图标', done: false, updatedAt: 1 }
  ];

  private toggleTask(targetId: number): void {
    this.tasks = this.tasks.map((task: SampleTask) => {
      if (task.id !== targetId) {
        return task;
      }
      return {
        id: task.id,
        title: task.title,
        owner: task.owner,
        done: !task.done,
        updatedAt: task.updatedAt + 1
      };
    });
  }

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('列表刷新示例')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')

      Text('列表项 key 使用 id 与 updatedAt 组合。数据变化后列表项会重建，避免只用 stable id 导致局部显示停留在旧状态。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(24)
        .width('100%')

      ForEach(this.tasks, (task: SampleTask) => {
        Row({ space: 12 }) {
          SymbolGlyph(task.done ? $r('sys.symbol.checkmark_circle_fill') : $r('sys.symbol.circle_grid_2x2'))
            .fontSize(28)
            .fontColor([task.done ? $r('sys.color.brand') : $r('sys.color.font_tertiary')])

          Column({ space: 5 }) {
            Text(task.title)
              .fontSize(17)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text(`${task.owner} / updatedAt ${task.updatedAt}`)
              .fontSize(13)
              .fontColor($r('sys.color.font_secondary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button(task.done ? '撤销' : '完成')
            .fontSize(14)
            .height(36)
            .onClick(() => {
              this.toggleTask(task.id);
            })
        }
        .width('100%')
        .padding(14)
        .borderRadius(8)
        .backgroundColor($r('sys.color.background_primary'))
      }, (task: SampleTask) => `${task.id}-${task.updatedAt}-${task.done}`)
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
          mainTitle: '列表'
        }
      }
    })
    .hideBackButton(true)
  }
}
