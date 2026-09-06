# 独立验收

- 职责：user-verifier
- 场景：02-generate-frequency-matrix
- 业务日：2026-09-06 Asia/Shanghai（周日）
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.schedules / public.tasks
- 结论：**PASS**

## 文案核对（必须带 id=）

grok-output.md 对 9 条 schedule 都写了 `id=N`，并说明新增/跳过和下次日期，没有只写标题。

| 文案 | 对照 expected |
| --- | --- |
| 新增 id=1 每天英语，下次 2026-09-07 | 命中；对应 next_run_at=1788710400 |
| 新增 id=2 每周日复盘，下次 2026-09-13 | 命中；对应 next_run_at=1789228800 |
| 跳过 id=3 每周一站会，下次 2026-09-07 | 命中；今天不生成 |
| 新增 id=4 每月6号账单，下次 2026-10-06 | 命中；对应 next_run_at=1791216000 |
| 跳过 id=5 每月15号回顾，下次 2026-09-15 | 命中；今天不生成 |
| 新增 id=6 每季末体检，下次 2026-12-06 | 命中；对应 next_run_at=1796486400 |
| 新增 id=7 每年生日，下次 2027-09-06 | 命中；对应 next_run_at=1820160000 |
| 跳过 id=8 明天才开始的每日，下次仍是 2026-09-07 | 命中；游标未到今天 |
| 新增 id=9 过期游标的周日（只生成今天，不补昨天），下次 2026-09-13 | 命中；对应 next_run_at=1789228800 |

开头也写了「过期游标只拨到今天，不补昨天」，与 expected 的不得回补昨天一致。

## DB 快照

查询时间：2026-09-06（独立验收只读，未改库）。

### public.schedules（9 行，字段：id / title / next_run_at）

| id | title | next_run_at | next_run_at(Asia/Shanghai) |
| --- | --- | --- | --- |
| 1 | 每天英语 | 1788710400 | 2026-09-07 00:00:00 |
| 2 | 每周日复盘 | 1789228800 | 2026-09-13 00:00:00 |
| 3 | 每周一站会 | 1788710400 | 2026-09-07 00:00:00 |
| 4 | 每月6号账单 | 1791216000 | 2026-10-06 00:00:00 |
| 5 | 每月15号回顾 | 1789401600 | 2026-09-15 00:00:00 |
| 6 | 每季末体检 | 1796486400 | 2026-12-06 00:00:00 |
| 7 | 每年生日 | 1820160000 | 2027-09-06 00:00:00 |
| 8 | 明天才开始的每日 | 1788710400 | 2026-09-07 00:00:00 |
| 9 | 过期游标的周日 | 1789228800 | 2026-09-13 00:00:00 |

### public.tasks（6 行，字段：id / title / schedule_id / planned_at）

| id | title | schedule_id | planned_at | planned_at(Asia/Shanghai) | status |
| --- | --- | --- | --- | --- | --- |
| 1 | 每天英语 | 1 | 1788624000 | 2026-09-06 00:00:00 | todo |
| 2 | 每周日复盘 | 2 | 1788624000 | 2026-09-06 00:00:00 | todo |
| 3 | 每月6号账单 | 4 | 1788624000 | 2026-09-06 00:00:00 | todo |
| 4 | 每季末体检 | 6 | 1788624000 | 2026-09-06 00:00:00 | todo |
| 5 | 每年生日 | 7 | 1788624000 | 2026-09-06 00:00:00 | todo |
| 6 | 过期游标的周日 | 9 | 1788624000 | 2026-09-06 00:00:00 | todo |

汇总：task_count=6，today_count=6，yesterday_count=0，todo_count=6；有任务的 schedule_id=[1,2,4,6,7,9]；无任务的 schedule_id=[3,5,8]。

## 对照 expected.md

| 期望 | 实测 |
| --- | --- |
| 今天必须生成：id=1 每天英语，next_run_at=1788710400 | 1 条 today todo（task id=1），next_run_at=1788710400 |
| 今天必须生成：id=2 每周日复盘，next_run_at=1789228800 | 1 条 today todo（task id=2），next_run_at=1789228800 |
| 今天必须生成：id=4 每月6号账单，next_run_at=1791216000 | 1 条 today todo（task id=3），next_run_at=1791216000 |
| 今天必须生成：id=6 每季末体检，next_run_at=1796486400 | 1 条 today todo（task id=4），next_run_at=1796486400 |
| 今天必须生成：id=7 每年生日，next_run_at=1820160000 | 1 条 today todo（task id=5），next_run_at=1820160000 |
| 今天必须生成：id=9 过期游标的周日，只补游标不补昨天，今天 1 条，next_run_at=1789228800 | 仅 1 条 today todo（task id=6，planned_at=1788624000），无 yesterday 行，next_run_at=1789228800 |
| 今天不得生成：id=3 每周一站会，无 task，next_run_at=1788710400 | 无 task，next_run_at=1788710400 |
| 今天不得生成：id=5 每月15号回顾，无 task，next_run_at=1789401600 | 无 task，next_run_at=1789401600 |
| 今天不得生成：id=8 明天才开始的每日，跳过且 next_run_at 仍为 1788710400 | 无 task，next_run_at=1788710400 |
| tasks 总数=6，全部 planned_at=1788624000，没有 yesterday 回补 | 6 条全部 planned_at=1788624000；planned_at=1788537600 的行数为 0 |
| 文案用 id= 说明新增/跳过/下次 | 9 条都带 id=，并写了新增或跳过及下次日期 |

## 问题列表

- 无。
