---
name: personal-os-report
description: 生成 Personal OS 早报、晚报或周报。在触发器或用户要求看今天待办、今晚回顾、本周回顾时使用。只读，不写库。不要用于生成今天的任务，也不要用于新建或改任务状态。
---

# 报告

根据触发文案选择早报、晚报或周报。用自然语言组织内容；查询先说中文意图，再用 SQL 校正。不要贴 SQL，不要写库。

## 数据

- 时区 `Asia/Shanghai`。日期边界用本地 00:00 Unix 秒。
- 日常只看 `is_deleted = false`。逻辑删除的行任何报告都不出现。
- `skipped` 不是完成，也不是待做。
- 本周：本周一 00:00 到下周一 00:00。
- 未来 30 天：明天 00:00 起 30 天。`:horizon_start` = 明天 00:00 再加 30 天。

## id 规则

列出的每一条都必须带 `id=N`，不要只写标题。例如：`📌 id=2 英语学习`。

## 文案排版

段落和任务行都用一个表情开头，用来分块，不要写成一片纯文字。

- 章节/段落：一行一个表情 + 标题
- 每条任务或规则：表情 + `id=N` + 标题，单独一行

建议：
- 摘要 ✨；待做 📌；进行中 🚧；完成 ✅；跳过 ⏭️；逾期 ⚠️；新增 🆕；规则/下次 📅；删除 🗑️；未来 🔮；早报 🌅；晚报 🌙；周报 📊；统计 📈

例：`🆕 id=3 英语学习`；`⏭️ id=2 每周一站会（今天不是周一）`

## 早报里各 status

| status | 今天 | 今天之前 |
|---|---|---|
| `todo` / `doing` | 进「今天待做」 | 进「今天之前未完成」 |
| `done` | 不出现（留给晚报） | 不出现 |
| `skipped` | 进「今天已跳过」，不进待做 | 不出现 |
| `is_deleted=true` | 不出现 | 不出现 |

待做里 `todo` 和 `doing` 都要列，可用标题区分「待做 / 进行中」，但仍以 `id=N` 为主。

## 晚报里各 status

| status | 规则 |
|---|---|
| `done` 且 `completed_at` 落在今天 | 进「今天完成」，含补做（`planned_at` 不是今天也算） |
| `todo` / `doing` 且 `planned_at < 今天` | 进「今天之前未完成」 |
| 今天的 `todo` / `doing` | 不算今天完成 |
| `skipped` | 不算完成；今天跳过的可在统计里写「id=N 已跳过，不算完成」 |
| `is_deleted=true` | 不出现 |

## 周报里各 status

- 本周完成：`completed_at` 在本周且 `done`
- 仍未完成：`todo` / `doing` 且 `planned_at < 明天`（含今天）
- `skipped` 不算完成，也不进仍未完成
- 未来 30 天：`next_run_at` 落在窗口内的 schedule 各一行（带 id、frequency、下次日期）+ 窗口内手工任务逐条（带 id）。合成一块。游标 `<= 今天` 的 schedule 不进未来。

## 早报查询校正

今天待做（todo + doing）：

```sql
select id, title, area, status, priority, planned_at
from tasks
where planned_at = :today_start
  and status in ('todo', 'doing')
  and is_deleted = false;
```

今天之前未完成：

```sql
select id, title, area, status, priority, planned_at
from tasks
where planned_at < :today_start
  and status in ('todo', 'doing')
  and is_deleted = false;
```

今天已跳过：

```sql
select id, title, area, status, planned_at
from tasks
where planned_at = :today_start
  and status = 'skipped'
  and is_deleted = false;
```

## 晚报查询校正

今天完成：

```sql
select id, title, area, status, priority, planned_at, completed_at
from tasks
where completed_at >= :today_start
  and completed_at < :tomorrow_start
  and status = 'done'
  and is_deleted = false;
```

今天之前未完成：

```sql
select id, title, area, status, priority, planned_at
from tasks
where planned_at < :today_start
  and status in ('todo', 'doing')
  and is_deleted = false;
```

今天跳过（统计用，不算完成）：

```sql
select id, title, status
from tasks
where planned_at = :today_start
  and status = 'skipped'
  and is_deleted = false;
```

## 周报查询校正

本周完成：

```sql
select id, title, area, status, completed_at
from tasks
where completed_at >= :week_start
  and completed_at < :next_week_start
  and status = 'done'
  and is_deleted = false;
```

仍未完成（含今天的 todo/doing）：

```sql
select id, title, area, status, priority, planned_at
from tasks
where planned_at < :tomorrow_start
  and status in ('todo', 'doing')
  and is_deleted = false;
```

未来 30 天重复规则：

```sql
select id, title, frequency, next_run_at
from schedules
where active = true
  and is_deleted = false
  and next_run_at >= :tomorrow_start
  and next_run_at < :horizon_start;
```

未来 30 天手工任务：

```sql
select id, title, area, status, planned_at
from tasks
where schedule_id is null
  and planned_at >= :tomorrow_start
  and planned_at < :horizon_start
  and is_deleted = false;
```
