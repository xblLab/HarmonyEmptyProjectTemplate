export interface SampleTask {
  id: number;
  title: string;
  owner: string;
  done: boolean;
  updatedAt: number;
  /** 截止时间（毫秒时间戳），示例用于演示第 9 节日期时间选择器与列表展示 */
  dueAt: number;
}

export class SampleTaskRepository {
  private static repo?: SampleTaskRepository;
  private ready: boolean = false;
  private nextId: number = 5;
  private tasks: SampleTask[] = [
    {
      id: 1,
      title: '根 Column 统一 padding',
      owner: '布局',
      done: true,
      updatedAt: 1,
      dueAt: new Date('2026-04-25T10:00:00').getTime()
    },
    {
      id: 2,
      title: 'Scroll 使用 Spring 回弹',
      owner: '滚动',
      done: true,
      updatedAt: 1,
      dueAt: new Date('2026-04-26T14:30:00').getTime()
    },
    {
      id: 3,
      title: 'ForEach key 拼接 updatedAt',
      owner: '刷新',
      done: false,
      updatedAt: 1,
      dueAt: new Date('2026-04-27T09:00:00').getTime()
    },
    {
      id: 4,
      title: '图标来自 symbolname',
      owner: '图标',
      done: false,
      updatedAt: 1,
      dueAt: new Date('2026-04-28T18:00:00').getTime()
    }
  ];

  static instance(): SampleTaskRepository {
    if (!SampleTaskRepository.repo) {
      SampleTaskRepository.repo = new SampleTaskRepository();
    }
    return SampleTaskRepository.repo;
  }

  isReady(): boolean {
    return this.ready;
  }

  async init(): Promise<void> {
    this.ready = true;
  }

  async queryTasks(): Promise<SampleTask[]> {
    return this.tasks.map((task: SampleTask) => {
      return this.cloneTask(task);
    });
  }

  async queryTask(id: number): Promise<SampleTask | undefined> {
    const task: SampleTask | undefined = this.tasks.find((item: SampleTask) => item.id === id);
    if (!task) {
      return undefined;
    }
    return this.cloneTask(task);
  }

  async toggleTask(id: number): Promise<void> {
    this.tasks = this.tasks.map((task: SampleTask) => {
      if (task.id !== id) {
        return task;
      }
      return {
        id: task.id,
        title: task.title,
        owner: task.owner,
        done: !task.done,
        updatedAt: task.updatedAt + 1,
        dueAt: task.dueAt
      };
    });
  }

  async saveTask(id: number, title: string, owner: string, dueAt: number): Promise<void> {
    const trimmedTitle: string = title.trim().length > 0 ? title.trim() : '未命名任务';
    const trimmedOwner: string = owner.trim().length > 0 ? owner.trim() : '未分类';
    if (id > 0) {
      this.tasks = this.tasks.map((task: SampleTask) => {
        if (task.id !== id) {
          return task;
        }
        return {
          id: task.id,
          title: trimmedTitle,
          owner: trimmedOwner,
          done: task.done,
          updatedAt: task.updatedAt + 1,
          dueAt: dueAt
        };
      });
      return;
    }

    this.tasks = [{
      id: this.nextId,
      title: trimmedTitle,
      owner: trimmedOwner,
      done: false,
      updatedAt: 1,
      dueAt: dueAt
    }, ...this.tasks];
    this.nextId += 1;
  }

  async deleteTask(id: number): Promise<void> {
    this.tasks = this.tasks.filter((task: SampleTask) => task.id !== id);
  }

  async appendTab1Task(version: number): Promise<void> {
    this.tasks = [{
      id: this.nextId,
      title: `Tab1 同步写入 ${version + 1}`,
      owner: '跨 Tab',
      done: false,
      updatedAt: 1,
      dueAt: Date.now()
    }, ...this.tasks];
    this.nextId += 1;
  }

  private cloneTask(task: SampleTask): SampleTask {
    return {
      id: task.id,
      title: task.title,
      owner: task.owner,
      done: task.done,
      updatedAt: task.updatedAt,
      dueAt: task.dueAt
    };
  }
}
