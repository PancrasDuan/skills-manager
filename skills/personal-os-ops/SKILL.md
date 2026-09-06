---
name: personal-os-ops
description: 在日常对话里新建或修改 Personal OS 的 task 与 schedule，包括状态流转、暂停和逻辑删除。用于自然语言操作数据。不要用于早报、晚报、周报；用户明确要求「生成今天」或「今天生效」时，交给 personal-os-generate-today。
---

# 日常对话

用自然语言理解用户要做什么，再执行单条业务写入。查询和更新前，用下面的 SQL 校正条件。

## 数据

- 时区 `Asia/Shanghai`。日期字段是本地当天 00:00 的 Unix 秒。
- `tasks`：`id, title, area, status, priority, planned_at, due_at, schedule_id, created_at, completed_at, is_deleted`
- `schedules`：`id, title, frequency, schedule, task_template, active, created_at, is_deleted, next_run_at`
- `area`：`work / life / study`；`status`：`todo / doing / done / skipped`；`priority`：1~3
- `frequency`：`daily / weekly / monthly / quarterly / yearly`
- `schedule` JSON 与 generate-today 相同：daily `{}`；其余用数组。weekly `{"weekdays":[1,2,3]}`（1=周一，7=周日）；monthly `{"days":[1,15]}`；quarterly `{"months_of_quarter":[1,3],"days":[6]}`；yearly `{"months":[3,9],"days":[1]}`。即使只有一项也用数组，例如 `{"weekdays":[3]}`。不要写单数 `weekday`/`day`/`month`/`month_of_quarter`
- 手工任务 `schedule_id is null`；生成任务 `schedule_id` 非空

## id 规则

- 改已有记录时，用用户给的 `id=N` / `idN` 定位，不要用标题匹配。
- 写完回读，给用户的文案必须带 `id=N`。例如：`✅ id=1 已完成`，不要说「英语学习已完成」。
- 新建后用 `returning id` 或回读，把新 id 告诉用户。

## 文案排版

段落和任务行都用一个表情开头，用来分块，不要写成一片纯文字。

- 章节/段落：一行一个表情 + 标题
- 每条任务或规则：表情 + `id=N` + 标题，单独一行

建议：
- 摘要 ✨；待做 📌；进行中 🚧；完成 ✅；跳过 ⏭️；逾期 ⚠️；新增 🆕；规则/下次 📅；删除 🗑️；未来 🔮；早报 🌅；晚报 🌙；周报 📊；统计 📈

例：`🆕 id=3 英语学习`；`⏭️ id=2 每周一站会（今天不是周一）`

## 允许

- 新建手工任务 / 新建 schedule
- 按 id 改标题、area、priority、due_at、当天计划
- 按 id 把 status 在 `todo / doing / done / skipped` 之间流转
- 按 id 暂停、恢复、逻辑删除 schedule 或 task
- 用户问某 id 状态、下次生成日时先查再答

普通单条写入可以直接做。DDL、物理删除、清空表先问用户。

## 不要做什么

- 不 `DELETE` / `TRUNCATE`，只用 `is_deleted = true`
- 不靠标题猜测要改哪一行
- 不把逾期任务自动改 `planned_at`，也不自动 `skipped`
- `done` 必须写 `completed_at`；`skipped` 不是删除
- 删 schedule 不级联任务
- 新建或改 schedule 默认明天生效，写入今天之后最近一次命中的 `next_run_at`
- 恢复暂停按明天起重算 `next_run_at`
- 用户说 `id=N 生成今天` / `id=N 今天生效` 时交给 `personal-os-generate-today`

## 查询校正

按 id 查任务：

```sql
select *
from tasks
where id = :id
  and is_deleted = false;
```

按 id 查规则：

```sql
select id, title, frequency, schedule, next_run_at, active, is_deleted
from schedules
where id = :id
  and is_deleted = false;
```

新建手工任务：

```sql
insert into tasks (
  title, area, status, priority,
  planned_at, due_at, schedule_id, is_deleted
) values (
  :title, :area, 'todo', :priority,
  :planned_at, :due_at, null, false
)
returning id;
```

标进行中：

```sql
update tasks
set status = 'doing'
where id = :id
  and is_deleted = false;
```

标完成：

```sql
update tasks
set status = 'done',
    completed_at = :now
where id = :id
  and is_deleted = false;
```

标跳过：

```sql
update tasks
set status = 'skipped'
where id = :id
  and is_deleted = false;
```

逻辑删除任务：

```sql
update tasks
set is_deleted = true
where id = :id;
```

新建 schedule：

```sql
insert into schedules (
  title, frequency, schedule, task_template,
  active, is_deleted, next_run_at
) values (
  :title, :frequency, :schedule, :task_template,
  true, false, :next_run_at
)
returning id;
```

暂停：

```sql
update schedules
set active = false
where id = :id
  and is_deleted = false;
```

恢复（明天起重算 next_run_at）：

```sql
update schedules
set active = true,
    next_run_at = :next_run_at
where id = :id
  and is_deleted = false;
```

逻辑删除 schedule：

```sql
update schedules
set is_deleted = true
where id = :id;
```
