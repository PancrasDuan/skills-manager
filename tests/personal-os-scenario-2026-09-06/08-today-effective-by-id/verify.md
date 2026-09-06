# 独立验收

- 职责：user-verifier
- 场景：08-today-effective-by-id
- 业务日：2026-09-06 Asia/Shanghai
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.schedules / public.tasks
- 结论：**PASS**

## 文案核对（必须带 id=）

grok-output.md 原文：

```
id=1 英语学习今天已生效。

新增 id=1 英语学习，规则 id=1，下次 2026-09-07。
```

| 文案 | 对照 expected |
| --- | --- |
| id=1 英语学习今天已生效 | 命中；带 id= |
| 新增 id=1 英语学习，规则 id=1，下次 2026-09-07 | 命中；任务 id=1，规则 id=1 |

- 任务与规则都用 `id=1`，没有只写标题。

## DB 快照

查询时间：2026-09-06（独立验收只读，未改库）。

计数：schedules=1（其中 is_deleted=true 的 0 行），tasks=1（is_deleted=true 的 0 行）。

### public.schedules（1 行）

| id | title | frequency | schedule | task_template | active | is_deleted | next_run_at | next_run_at(Asia/Shanghai) | created_at | created_at(Asia/Shanghai) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | daily | {} | {"area": "study", "priority": 2} | true | false | 1788710400 | 2026-09-07 00:00:00 | 1788658130 | 2026-09-06 09:28:50 |

### public.tasks（1 行）

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | due_at | schedule_id | completed_at | is_deleted | created_at | created_at(Asia/Shanghai) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | study | todo | 2 | 1788624000 | 2026-09-06 00:00:00 | null | 1 | null | false | 1788658331 | 2026-09-06 09:32:11 |

## 对照 expected.md

| 期望 | 实测 |
| --- | --- |
| 生成 tasks 1 条，schedule_id=1，planned_at=1788624000，status=todo | 命中；仅 1 条，id=1，schedule_id=1，planned_at=1788624000，status=todo |
| schedules id=1 next_run_at=1788710400 | 命中；id=1，next_run_at=1788710400（2026-09-07 00:00:00） |
| 文案带任务 id 和规则 id=1 | 命中；「新增 id=1 … 规则 id=1」 |

## 问题列表

- 无。
