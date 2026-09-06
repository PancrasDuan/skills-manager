# 独立验收

- 职责：user-verifier
- 场景：03-ops-status-by-id
- 业务日：2026-09-06 Asia/Shanghai
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.tasks / public.schedules
- 结论：**PASS**

## 文案核对（必须带 id=）

grok-output.md 原文：

```
三条都改好了。

- id=1 已完成
- id=2 开始做
- id=3 已跳过
```

| 文案 | 对照 expected |
| --- | --- |
| id=1 已完成 | 命中；带 id=，不是「英语学习已完成」 |
| id=2 开始做 | 命中；带 id=，对应 doing |
| id=3 已跳过 | 命中；带 id=，对应 skipped |

- 三条都是 `id=N 状态` 形式，没有只写标题。

## DB 快照

查询时间：2026-09-06（独立验收只读，未改库）。

### public.schedules（0 行）

`[]`

### public.tasks（3 行）

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | completed_at | completed_at(Asia/Shanghai) | is_deleted |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | study | done | 2 | 1788624000 | 2026-09-06 00:00:00 | 1788654295 | 2026-09-06 08:24:55 | false |
| 2 | 写周报 | work | doing | 1 | 1788624000 | 2026-09-06 00:00:00 | null |  | false |
| 3 | 跑步 | life | skipped | 3 | 1788624000 | 2026-09-06 00:00:00 | null |  | false |

补充：`due_at=null`，`schedule_id=null`，`created_at=1788654193`。

## 对照 expected.md

| 期望 | 实测 |
| --- | --- |
| id=1 status=done，completed_at 落在 [1788624000, 1788710400)，planned_at 仍 1788624000 | status=done，completed_at=1788654295（当天 08:24:55），planned_at=1788624000 |
| id=2 status=doing，completed_at 为空 | status=doing，completed_at=null |
| id=3 status=skipped，completed_at 为空 | status=skipped，completed_at=null |
| 文案是「id=1 已完成」这种形式，不能出现「英语学习已完成」而不带 id | 三条都带 id=，无标题替代 |

## 问题列表

- 无。
