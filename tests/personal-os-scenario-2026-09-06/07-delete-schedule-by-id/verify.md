# 独立验收

- 职责：user-verifier
- 场景：07-delete-schedule-by-id
- 业务日：2026-09-06 Asia/Shanghai
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.schedules / public.tasks
- 结论：**PASS**

## 文案核对（必须带 id=）

grok-output.md 原文：

```
id=1 已删除，之后不会再自动生成。

已经生成的任务 id=1 先留着。
```

| 文案 | 对照 expected |
| --- | --- |
| id=1 已删除 | 命中；带 id=，对应「已删除/已关掉」，不是只写标题 |
| 已经生成的任务 id=1 先留着 | 命中；任务 id=1 保留 |

- 规则删除与已生成任务都用 `id=1`，没有只说「英语学习」。

## DB 快照

查询时间：2026-09-06（独立验收只读，未改库）。

计数：schedules=1（其中 is_deleted=true 的 1 行），tasks=1（is_deleted=true 的 0 行）。

### public.schedules（1 行，行还在）

| id | title | frequency | schedule | task_template | active | is_deleted | next_run_at | next_run_at(Asia/Shanghai) | created_at | created_at(Asia/Shanghai) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | daily | {} | {"area":"study","priority":2} | true | true | 1788710400 | 2026-09-07 00:00:00 | 1788656923 | 2026-09-06 09:08:43 |

### public.tasks（1 行）

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | due_at | schedule_id | completed_at | is_deleted | created_at | created_at(Asia/Shanghai) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | study | todo | 2 | 1788624000 | 2026-09-06 00:00:00 | null | 1 | null | false | 1788656923 | 2026-09-06 09:08:43 |

## 对照 expected.md

| 期望 | 实测 |
| --- | --- |
| schedules id=1 is_deleted=true，行还在 | 命中；id=1 仍存在，is_deleted=true，不是物理删除 |
| tasks id=1 is_deleted=false，schedule_id=1 | 命中；status 仍为 todo，未级联删除 |
| 文案：id=1 已删除/已关掉，任务 id=1 保留 | 命中 |

补充（不构成失败）：skill 的逻辑删除只写 `is_deleted=true`，未要求改 `active`；实测 `active` 仍为 true。

## 问题列表

- 无。
