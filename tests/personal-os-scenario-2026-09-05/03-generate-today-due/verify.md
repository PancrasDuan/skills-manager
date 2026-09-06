# 验收结果

- 结论：PASS
- 职责：user-verifier
- 场景：03-generate-today-due
- 核对日：2026-09-05 Asia/Shanghai
- 数据来源：Supabase execute_sql（project_id=zvdcjzjfhkjasikchceo），只读查询 public.tasks、public.schedules
- 未改库

## DB 快照

查询时间对应库内 created_at 已存在记录，未执行 INSERT/UPDATE/DELETE。

### public.tasks（1 行）

| 字段 | 值 |
| --- | --- |
| id | 1 |
| title | 英语学习 |
| area | study |
| status | todo |
| priority | 2 |
| planned_at | 1788537600（2026-09-05T00:00:00+08:00） |
| due_at | null |
| schedule_id | 1 |
| created_at | 1788621085（2026-09-05T23:11:25+08:00） |
| completed_at | null |
| is_deleted | false |

### public.schedules（1 行）

| 字段 | 值 |
| --- | --- |
| id | 1 |
| title | 英语学习 |
| frequency | daily |
| schedule | {} |
| task_template | {"area":"study","priority":2} |
| active | true |
| created_at | 1788620664（2026-09-05T23:04:24+08:00） |
| is_deleted | false |
| next_run_at | 1788624000（2026-09-06T00:00:00+08:00，明天） |

## 字段核对

| 期望 | 实测 | 结果 |
| --- | --- | --- |
| tasks 新增 1 行 | public.tasks 共 1 行 | 通过 |
| title=英语学习 | 英语学习 | 通过 |
| area=study | study | 通过 |
| priority=2 | 2 | 通过 |
| status=todo | todo | 通过 |
| planned_at=1788537600 | 1788537600 | 通过 |
| due_at=null | null | 通过 |
| is_deleted=false | false | 通过 |
| schedule_id 指向该 schedule | tasks.schedule_id=1，schedules.id=1 | 通过 |
| schedules.next_run_at=1788624000（明天） | 1788624000 | 通过 |

## 文案核对

grok-output.md 原文：

> 今天已生成「英语学习」。
>
> - 新增：「英语学习」（学习，优先级 2），安排在今天。
> - 因已有活任务跳过：无。
> - 因游标未到/不命中跳过：无。
> - 游标推进：「英语学习」下次生成日是 2026-09-06（明天）。

| 期望 | 实测 | 结果 |
| --- | --- | --- |
| 文案说明新增了英语学习 | 标题与「新增」项均写明「英语学习」 | 通过 |
| 文案提到下次为明天 | 「下次生成日是 2026-09-06（明天）」 | 通过 |

文案与库内任务/游标一致：新增任务对应今天 planned_at，游标已推进到明天。

## 问题列表

无。

