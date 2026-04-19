export interface SampleTask {
  id: number;
  title: string;
  owner: string;
  done: boolean;
  updatedAt: number;
}

export class SampleTaskRepository {
  private static repo?: SampleTaskRepository;
  private ready: boolean = false;
  private nextId: number = 5;
  private tasks: SampleTask[] = [
    { id: 1, title: '根 Column 统一 padding', owner: '布局', done: true, updatedAt: 1 },
    { id: 2, title: 'Scroll 使用 Spring 回弹', owner: '滚动', done: true, updatedAt: 1 },
    { id: 3, title: 'ForEach key 拼接 updatedAt', owner: '刷新', done: false, updatedAt: 1 },
    { id: 4, title: '图标来自 symbolname', owner: '图标', done: false, updatedAt: 1 }
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
        updatedAt: task.updatedAt + 1
      };
    });
  }

  async saveTask(id: number, title: string, owner: string): Promise<void> {
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
          updatedAt: task.updatedAt + 1
        };
      });
      return;
    }

    this.tasks = [{
      id: this.nextId,
      title: trimmedTitle,
      owner: trimmedOwner,
      done: false,
      updatedAt: 1
    }, ...this.tasks];
    this.nextId += 1;
  }

  async appendTab1Task(version: number): Promise<void> {
    this.tasks = [{
      id: this.nextId,
      title: `Tab1 同步写入 ${version + 1}`,
      owner: '跨 Tab',
      done: false,
      updatedAt: 1
    }, ...this.tasks];
    this.nextId += 1;
  }

  private cloneTask(task: SampleTask): SampleTask {
    return {
      id: task.id,
      title: task.title,
      owner: task.owner,
      done: task.done,
      updatedAt: task.updatedAt
    };
  }
}
