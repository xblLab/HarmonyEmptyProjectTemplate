import { SampleTask, SampleTaskRepository } from '../../model/SampleTaskRepository';

export interface SampleTaskEditParams {
  taskId: number;
}

@Builder
export function SampleTaskEditPageBuilder() {
  SampleTaskEditPage();
}

@Component
struct SampleTaskEditPage {
  private taskId: number = 0;
  private reloadToken: number = 0;

  @StorageLink('sample_task_version') @Watch('onTaskVersionChanged') taskVersion: number = 0;
  @State private pageTitle: string = '新增列表项';
  @State private titleText: string = '';
  @State private ownerText: string = '';

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
  }

  private async saveTask(): Promise<void> {
    const repo: SampleTaskRepository = await this.ensureRepo();
    await repo.saveTask(this.taskId, this.titleText, this.ownerText);
    this.taskVersion += 1;
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        Text('保存后，列表页通过 @StorageLink 版本信号重新 loadTasks。')
          .fontSize(15)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(22)
          .width('100%')

        TextInput({ placeholder: '任务标题', text: this.titleText })
          .width('100%')
          .onChange((value: string) => {
            this.titleText = value;
          })

        TextInput({ placeholder: '分类', text: this.ownerText })
          .width('100%')
          .onChange((value: string) => {
            this.ownerText = value;
          })

        Button('保存并通知列表页')
          .width('100%')
          .onClick(() => {
            void this.saveTask();
          })
      }
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title(this.pageTitle)
    .onReady((context: NavDestinationContext) => {
      const p = context.pathInfo.param as SampleTaskEditParams;
      if (p && p.taskId > 0) {
        this.taskId = p.taskId;
        void this.loadTask();
      }
    })
    .onBackPressed(() => {
      return false;
    });
  }
}
