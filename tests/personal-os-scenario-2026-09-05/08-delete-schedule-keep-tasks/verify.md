# 验收结果

- 结论：PASS
- 职责：user-verifier
- 场景：08-delete-schedule-keep-tasks
- 验收时间：2026-09-06（查询时刻库内 `now()` = 2026-09-05 16:00:22.979937+00）
- 项目：`zvdcjzjfhkjasikchceo`
- 方法：只读查询 `public.schedules`、`public.tasks`；对照本目录 `expected.md` 与 `grok-output.md`。不信任 Grok 自述，未改库。

## DB 快照

查询范围：`select * from public.schedules`、`select * from public.tasks`。当前各 1 行。

### public.schedules

| 字段 | 值 |
| --- | --- |
| id | 1 |
| title | 英语学习 |
| frequency | daily |
| schedule | {} |
| task_template | {"area":"study","priority":2} |
| active | true |
| created_at | 1788623774 |
| is_deleted | true |
| next_run_at | 1788624000 |

### public.tasks

| 字段 | 值 |
| --- | --- |
| id | 1 |
| title | 英语学习 |
| area | study |
| status | todo |
| priority | 2 |
| planned_at | 1788537600 |
| due_at | null |
| schedule_id | 1 |
| created_at | 1788623774 |
| completed_at | null |
| is_deleted | false |

### expected.md 字段核对

| 期望 | 实际 | 结果 |
| --- | --- | --- |
| schedules.is_deleted = true，且没有物理删除 | 规则行仍在，id=1，title=英语学习，is_deleted=true | 通过 |
| 对应 task 仍在，is_deleted=false | 任务行仍在，id=1，title=英语学习，is_deleted=false | 通过 |
| task.schedule_id 仍指向原 id | schedule_id=1，等于原 schedule.id | 通过 |

补充观察（不作为失败项）：该 schedule 的 `active` 仍为 true。`expected.md` 未要求改 `active`，本验收不以该字段判定失败。

## 文案核对

用户命令：把英语学习这个周期规则删掉。已经生成的任务先留着。

`grok-output.md` 原文：

> 「英语学习」这个周期规则已经删掉，之后不会再自动生成新任务。
>
> 已经生成的「英语学习」任务还留着，目前仍是待做，没有一起删。如果之后也要去掉这条任务，跟我说一声就行。

| 期望 | 文案 | 结果 |
| --- | --- | --- |
| 说明规则已删 | 「英语学习」这个周期规则已经删掉 | 通过 |
| 说明历史任务保留 | 已经生成的「英语学习」任务还留着……没有一起删 | 通过 |

文案与库状态一致：规则软删、任务未删且 `status=todo`（待做）。未把任务说成已删，也未声称规则被物理删除。

## 问题列表

无。
