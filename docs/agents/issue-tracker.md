# 任务管理：本地 Markdown

- 每项功能一个目录：`.scratch/<feature-slug>/`。
- 规格文件：`.scratch/<feature-slug>/spec.md`。
- 每个任务独立存放：
  `.scratch/<feature-slug>/issues/<NN>-<slug>.md`，从 01 编号。
- 任务顶部使用 Status 记录状态，使用 Blocked by 记录依赖。
- 按依赖顺序实施，前置任务完成后再开始后续任务。
- 讨论追加到任务文件的 Comments 章节。
- “发布到任务系统”表示创建或更新对应 Markdown 文件。
- “读取任务”表示读取用户指定路径或编号对应的文件。
