---
name: personal-os-generate-today
description: 为 Personal OS 生成当天由 schedule 投影出的任务实例。在触发器或用户明确要求「生成今天」「今天生效」时使用。不要用于早报、晚报、周报，也不要用于普通新建任务或状态流转。
---

# 生成今天

被触发后，只把「今天应该出现」的 schedule 实例写入 `tasks`，并推进 `schedules.next_run_at`。用自然语言判断和汇报，用 SQL 校正查询。

## 数据

- 时区 `Asia/Shanghai`。`planned_at` / `next_run_at` 都是本地当天 00:00 的 Unix 秒。
- `schedules`：`id, title, frequency, schedule, task_template, active, created_at, is_deleted, next_run_at`
- `tasks`：`id, title, area, status, priority, planned_at, due_at, schedule_id, created_at, completed_at, is_deleted`
- 规则真相是 `frequency + schedule`；`next_run_at` 是下次应生成日的游标。
- `area`：`work / life / study`；`priority`：1~3
- 用户指定某一条时用 `id=N`，不要用标题当主键。

## schedule JSON

除 `daily` 外，周期点都用数组，今天落在其中任一组合就算命中。同一维度是「或」，不同维度是「且」。没有这一天（如 2 月 31 号）则该点不命中。

| frequency | schedule | 今天命中 |
|---|---|---|
| `daily` | `{}` | 每天 |
| `weekly` | `{"weekdays":[1,2,3]}` ISO，1=周一，7=周日 | 今天星期几在列表里。例：周一到周三 |
| `monthly` | `{"days":[1,15]}` | 今天几号在列表里 |
| `quarterly` | `{"months_of_quarter":[1,3],"days":[6]}` | 本季第几月在列表里，且几号在列表里。Q1=1-3月，Q2=4-6，Q3=7-9，Q4=10-12 |
| `yearly` | `{"months":[3,9],"days":[1]}` | 月份在列表里，且几号在列表里 |

只写一个值时，也可写成单数，按只有一项的数组处理：`{"weekday":3}` 等于 `{"weekdays":[3]}`；`day` / `month` / `month_of_quarter` 同理。

JSON 缺字段或看不懂：跳过并说明，不要猜。

下一次命中 = 今天之后（不含今天）最近一个命中日。`daily` 就是明天。例如 `weekdays=[1,2,3]` 且今天是周三，下次是下周一。

## 做什么

默认全量。用户说 `id=N 生成今天` / `id=N 今天生效` 时只处理那一条。

1. 算出 `today_start`。
2. 查出有效且游标已到期或为空的 schedule。
3. 游标 `< 今天`：按规则往前拨到 `>= 今天`，**不补历史任务**。
4. 游标 `= 今天` 且今天命中：没有未删除的当天生成任务就插入 `todo`，然后把 `next_run_at` 推到今天之后最近一次命中。已有活任务也要推进游标。逻辑删除过的不算活任务，可以再生成。
5. 游标 `= 今天` 但今天不命中：不插入，把游标推到今天之后最近一次命中。
6. 游标 `> 今天`：跳过，不改游标。
7. 游标为空或 JSON 看不懂：跳过并说明。

普通触发尊重游标。用户明确 `id=N 今天生效` 且今天命中时，把该条 `next_run_at` 改成今天再生成。

插入后必须 `returning id`（或回读）拿到自增 id。

插入字段：`title` 默认用 schedule 标题；`area` / `priority` 来自 `task_template`，缺省 `area='life'`、`priority=2`；`status='todo'`；`planned_at=today_start`；`due_at=null`；`schedule_id` 指向该规则。

## 不要做什么

- 不生成明天及以后，不补昨天及以前
- 不 UPDATE 已有任务，不处理手工任务
- 对 `schedules` 只允许改 `next_run_at`
- 不 `DELETE` / `TRUNCATE`，不改 schema

## 输出

给用户的文案每条都带 `id=N`，不要只写标题。不要贴 SQL。

## 文案排版

段落和任务行都用一个表情开头，用来分块，不要写成一片纯文字。

- 章节/段落：一行一个表情 + 标题
- 每条任务或规则：表情 + `id=N` + 标题，单独一行

建议：
- 摘要 ✨；待做 📌；进行中 🚧；完成 ✅；跳过 ⏭️；逾期 ⚠️；新增 🆕；规则/下次 📅；删除 🗑️；未来 🔮；早报 🌅；晚报 🌙；周报 📊；统计 📈

例：`🆕 id=3 英语学习`；`⏭️ id=2 每周一站会（今天不是周一）`

## 查询校正

查出到期或游标为空的有效规则：

```sql
select id, title, frequency, schedule, task_template, next_run_at
from schedules
where active = true
  and is_deleted = false
  and (next_run_at is null or next_run_at <= :today_start);
```

查出今天已有的生成任务：

```sql
select id, schedule_id, status
from tasks
where schedule_id is not null
  and planned_at = :today_start
  and is_deleted = false;
```

插入并返回 id：

```sql
insert into tasks (
  title, area, status, priority,
  planned_at, due_at, schedule_id, is_deleted
) values (
  :title, :area, 'todo', :priority,
  :today_start, null, :schedule_id, false
)
returning id;
```

推进下次生成日：

```sql
update schedules
set next_run_at = :next_run_at
where id = :id
  and is_deleted = false;
```
