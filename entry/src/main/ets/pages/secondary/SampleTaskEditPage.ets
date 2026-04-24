import { SampleTask, SampleTaskRepository } from '../../model/SampleTaskRepository';
import { formatDateTimeMs } from '../../utils/formatDateTime';

export interface SampleTaskEditParams {
  taskId: number;
}

@Builder
export function SampleTaskEditPageBuilder() {
  SampleTaskEditPage();
}

@Component
struct SampleTaskEditPage {
  scroller: Scroller = new Scroller();
  private taskId: number = 0;
  private reloadToken: number = 0;

  @Consume('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink('sample_task_version') @Watch('onTaskVersionChanged') taskVersion: number = 0;
  @State private pageTitle: string = '新增列表项';
  @State private titleText: string = '';
  @State private ownerText: string = '';
  @State private selectedDueAt: Date = new Date();

  private onTaskVersionChanged(): void {
    if (this.taskId > 0) {
      void this.loadTask();
    }
  }

  private async ensureRepo(): Promise<SampleTaskRepository> {
    const repo: SampleTaskRepository = SampleTaskRepository.instance();
    if (!repo.isReady()) {
      await repo.init();
    }
    return repo;
  }

  private async loadTask(): Promise<void> {
    const token: number = ++this.reloadToken;
    const repo: SampleTaskRepository = await this.ensureRepo();
    const task: SampleTask | undefined = await repo.queryTask(this.taskId);
    if (token !== this.reloadToken || !task) {
      return;
    }
    this.pageTitle = '编辑列表项';
    this.titleText = task.title;
    this.ownerText = task.owner;
    this.selectedDueAt = new Date(task.dueAt);
  }

  private openDueDateTimePicker(): void {
    this.getUIContext().showDatePickerDialog({
      start: new Date('2000-01-01'),
      end: new Date('2100-12-31'),
      selected: this.selectedDueAt,
      showTime: true,
      useMilitaryTime: true,
      onDateAccept: (value: Date) => {
        const date: Date = new Date(value.getTime());
        date.setSeconds(0);
        date.setMilliseconds(0);
        this.selectedDueAt = date;
      }
    });
  }

  private async saveTask(): Promise<void> {
    const repo: SampleTaskRepository = await this.ensureRepo();
    await repo.saveTask(this.taskId, this.titleText, this.ownerText, this.selectedDueAt.getTime());
    this.taskVersion += 1;
    this.pageInfos.pop();
  }

  private async deleteTask(): Promise<void> {
    if (this.taskId <= 0) {
      return;
    }
    const repo: SampleTaskRepository = await this.ensureRepo();
    await repo.deleteTask(this.taskId);
    this.taskVersion += 1;
    this.pageInfos.pop();
  }

  @Builder
  private buildContentView() {
    Column({ space: 16 }) {
      Text('符合第 10.1 节：保存或删除成功后自动返回列表；表单项带标签与 placeholder；截止时间用系统日期时间选择器（第 9 节），不用文本框输入时间。')
        .fontSize(15)
        .fontColor($r('sys.color.font_secondary'))
        .lineHeight(22)
        .width('100%')

      Text('任务标题')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
      TextInput({ placeholder: '例如：完成首页改版', text: this.titleText })
        .width('100%')
        .onChange((value: string) => {
          this.titleText = value;
        })

      Text('负责人 / 分类')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
      TextInput({ placeholder: '例如：产品组、前端', text: this.ownerText })
        .width('100%')
        .onChange((value: string) => {
          this.ownerText = value;
        })

      Text('截止时间')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
      Row({ space: 12 }) {
        Text(formatDateTimeMs(this.selectedDueAt.getTime()))
          .fontSize(16)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
        Button('选择')
          .fontSize(14)
          .height(36)
          .onClick(() => {
            this.openDueDateTimePicker();
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 10 })
      .borderRadius(8)
      .backgroundColor($r('sys.color.background_primary'))

      Button('保存并返回列表')
        .width('100%')
        .onClick(() => {
          void this.saveTask();
        })

      if (this.taskId > 0) {
        Button('删除此项并返回')
          .width('100%')
          .fontColor($r('sys.color.ohos_id_color_warning'))
          .backgroundColor($r('sys.color.background_primary'))
          .borderWidth(1)
          .borderColor($r('sys.color.ohos_id_color_warning'))
          .onClick(() => {
            void this.deleteTask();
          })
      }
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
    .title(this.pageTitle)
    .onReady((context: NavDestinationContext) => {
      const p = context.pathInfo.param as SampleTaskEditParams;
      if (p && p.taskId > 0) {
        this.taskId = p.taskId;
        void this.loadTask();
      } else {
        this.taskId = 0;
        this.pageTitle = '新增列表项';
        this.selectedDueAt = new Date();
      }
    })
    .onBackPressed(() => {
      return false;
    });
  }
}
