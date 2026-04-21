import { HdsNavDestination, HdsNavDestinationAttribute, ScrollEffectType } from '@kit.UIDesignKit';
import { LengthMetrics } from '@kit.ArkUI';
import { NAVIGATION_TITLE_BAR_HEIGHT } from '../config/Constants';
import { SampleTask, SampleTaskRepository } from '../model/SampleTaskRepository';
import { formatDateTimeMs } from '../utils/formatDateTime';
import { SampleTaskEditParams } from './secondary/SampleTaskEditPage';

@Component
export struct TabPage3 {
  scroller: Scroller = new Scroller();
  private reloadToken: number = 0;

  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('sample_task_version') @Watch('onTaskVersionChanged') taskVersion: number = 0;
  @State private tasks: SampleTask[] = [];

  aboutToAppear(): void {
    void this.loadTasks();
  }

  private onTaskVersionChanged(): void {
    void this.loadTasks();
  }

  private async ensureRepo(): Promise<SampleTaskRepository> {
    const repo: SampleTaskRepository = SampleTaskRepository.instance();
    if (!repo.isReady()) {
      await repo.init();
    }
    return repo;
  }

  private async loadTasks(): Promise<void> {
    const token: number = ++this.reloadToken;
    const repo: SampleTaskRepository = await this.ensureRepo();
    const tasks: SampleTask[] = await repo.queryTasks();
    if (token !== this.reloadToken) {
      return;
    }
    this.tasks = tasks;
  }

  private async toggleTask(targetId: number): Promise<void> {
    const repo: SampleTaskRepository = await this.ensureRepo();
    await repo.toggleTask(targetId);
    this.taskVersion += 1;
  }

  private openEditPage(taskId: number): void {
    const params: SampleTaskEditParams = {
      taskId: taskId
    };
    this.pageInfos.pushPath({
      name: 'SampleTaskEditPage',
      param: params
    });
  }

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('列表项 key 使用 id 与 updatedAt 组合。数据变化后列表项会重建，避免只用 stable id 导致局部显示停留在旧状态。')
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(24)
        .width('100%')

      Text('二级页示例遵循第 10.1 节：保存/删除后自动 pop 回列表；表单字段带标签与 placeholder；截止时间用系统日期时间弹窗（第 9 节），不用文本框输入。')
        .fontSize(14)
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight(20)
        .width('100%')

      Text(`同步版本 ${this.taskVersion}。Tab1 写入、新增页保存、编辑页保存、列表内切换完成状态都会更新这个版本。`)
        .fontSize(14)
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight(20)
        .width('100%')

      Button('进入新增页面')
        .width('100%')
        .onClick(() => {
          this.openEditPage(0);
        })

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
            Text(`${task.owner} · 截止 ${formatDateTimeMs(task.dueAt)}`)
              .fontSize(13)
              .fontColor($r('sys.color.font_secondary'))
            Text(`updatedAt ${task.updatedAt}`)
              .fontSize(12)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button(task.done ? '撤销' : '完成')
            .fontSize(14)
            .height(36)
            .onClick(() => {
              void this.toggleTask(task.id);
            })

          Button('编辑')
            .fontSize(14)
            .height(36)
            .onClick(() => {
              this.openEditPage(task.id);
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
          mainTitle: '规范'
        }
      }
    })
    .hideBackButton(true)
  }
}
