# 独立验收

- 职责：user-verifier
- 场景：01-ops-create-frequencies
- 业务日：2026-09-06 Asia/Shanghai
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.schedules / public.tasks
- 结论：**PASS**

## 文案是否每条都有 id=

- 是。grok-output.md 三条规则分别写了 `id=1`、`id=2`、`id=3`，且与库中 schedules.id 一致。
- 三条都说明了下次日期：2026-09-07 / 2026-09-13 / 2026-10-06。
- 文案另有「默认明天生效，今天不会自动生成任务」，符合 expected 的「明天生效/下次日期」。

## DB 快照

查询时间：2026-09-06（独立验收只读）。

### public.schedules（3 行）

| id | title | frequency | schedule | task_template | active | is_deleted | next_run_at | next_run_at(Asia/Shanghai) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | daily | {} | {"area":"study","priority":2} | true | false | 1788710400 | 2026-09-07T00:00:00+08:00 |
| 2 | 每周日复盘 | weekly | {"weekday":7} | {"area":"life","priority":2} | true | false | 1789228800 | 2026-09-13T00:00:00+08:00 |
| 3 | 每月6号账单 | monthly | {"day":6} | {"area":"work","priority":1} | true | false | 1791216000 | 2026-10-06T00:00:00+08:00 |

### public.tasks（0 行）

`[]`

## 对照 expected.md

| 期望 | 实测 |
| --- | --- |
| 3 条 schedules，is_deleted=false，active=true | 3 条，全部 is_deleted=false 且 active=true |
| 每天：frequency=daily，schedule={}，next_run_at=1788710400（2026-09-07） | id=1 命中 |
| 每周日：frequency=weekly，schedule weekday=7，next_run_at=1789228800（2026-09-13） | id=2 命中 |
| 每月6号：frequency=monthly，schedule day=6，next_run_at=1791216000（2026-10-06） | id=3 命中 |
| tasks=0 | 0 |
| 文案对三条都出现 id=N，且说明明天生效/下次日期 | 命中 |

## 问题列表

- 无。
