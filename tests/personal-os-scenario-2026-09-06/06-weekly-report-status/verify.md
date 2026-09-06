# 独立验收 · 06-weekly-report-status

- 职责：user-verifier
- 场景：06-weekly-report-status
- 业务日：2026-09-06 Asia/Shanghai（周日，ISO weekday=7）
- 核验时间：2026-09-06（独立只读验收，不信任 Grok 自述）
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.tasks / public.schedules
- 对照：command.md、expected.md、grok-output.md；未改库
- 结论：**PASS**

## 结论

PASS。当前库状态与周报文案均符合 expected.md：本周完成必须出现 id=1 本周完成稿；仍未完成含今天必须出现 id=2 今天待做、id=3 今天进行中、id=4 逾期待做；不得把 id=5 今天跳过放进仍未完成或本周完成；未来 30 天同一块必须出现 schedule id=1 英语学习一行 + id=6 未来手工；不得出现 schedule id=2 已到期未推进；每条列出的行都带 `id=`。未见写库或把 daily 展开成 30 条的痕迹。

## DB 快照

查询时间点行数：

| 表 | 总行数 | is_deleted=false |
|---|---|---|
| public.tasks | 6 | 6 |
| public.schedules | 2 | 2 |

业务日边界：today_start=1788624000（2026-09-06 00:00:00 CST），tomorrow_start=1788710400（2026-09-07 00:00:00 CST），week_start=1788105600（2026-08-31 00:00:00 CST），next_week_start=1788710400，horizon_start=1791302400（2026-10-07 00:00:00 CST）。本周窗口是周一 00:00 到下周一 00:00。

### public.tasks

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | completed_at | completed_at(Asia/Shanghai) | schedule_id | is_deleted | 按 expected 归类 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 本周完成稿 | work | done | 1 | 1788105600 | 2026-08-31 00:00:00 | 1788364800 | 2026-09-03 00:00:00 | null | false | 本周完成 |
| 2 | 今天待做 | study | todo | 2 | 1788624000 | 2026-09-06 00:00:00 | null |  | 1 | false | 仍未完成（今天） |
| 3 | 今天进行中 | work | doing | 1 | 1788624000 | 2026-09-06 00:00:00 | null |  | null | false | 仍未完成（今天） |
| 4 | 逾期待做 | work | todo | 1 | 1788364800 | 2026-09-03 00:00:00 | null |  | null | false | 仍未完成（逾期） |
| 5 | 今天跳过 | life | skipped | 3 | 1788624000 | 2026-09-06 00:00:00 | null |  | null | false | 不得放进本周完成或仍未完成 |
| 6 | 未来手工 | work | todo | 2 | 1789488000 | 2026-09-16 00:00:00 | null |  | null | false | 未来 30 天手工 |

补充：6 行 due_at=null；created_at 全部为 1788656020（2026-09-06 08:53:40 Asia/Shanghai）。

### public.schedules

| id | title | frequency | active | is_deleted | next_run_at | next_run_at(Asia/Shanghai) | task_template | 按 expected 归类 |
|---|---|---|---|---|---|---|---|---|
| 1 | 英语学习 | daily | true | false | 1789488000 | 2026-09-16 00:00:00 | area=study, priority=2 | 未来 30 天重复规则一行 |
| 2 | 已到期未推进 | daily | true | false | 1788624000 | 2026-09-06 00:00:00 | area=life, priority=3 | 游标已到今天，不得进未来 30 天 |

两行 created_at 同为 1788656020（2026-09-06 08:53:40 Asia/Shanghai）。

关键字段解读：

- 本周完成按 completed_at 落在 [week_start, next_week_start) 且 status=done：只有 id=1，完成于 2026-09-03。
- 仍未完成按 planned_at < tomorrow_start 且 status in (todo, doing)：id=4（2026-09-03，逾期 3 天）、id=2（当天 todo）、id=3（当天 doing）。含今天，不只是今天之前。
- id=5 status=skipped，planned_at 当天。skipped 不算完成，也不进仍未完成。
- 未来 30 天重复规则按 active、未删除、next_run_at >= tomorrow_start 且 < horizon_start：只有 schedule id=1 英语学习，下次 2026-09-16。
- 未来 30 天手工按 schedule_id is null 且 planned_at 落在同一窗口：只有 id=6 未来手工。
- schedule id=2 next_run_at=今天 00:00，游标 <= 今天，不进未来窗口。

### 只读约束

验收会话只跑 SELECT / list_tables，未执行 INSERT/UPDATE/DELETE/DDL。

- 行数仍是 tasks=6 / schedules=2，与 seed.sql 的 6 条 task insert + 2 条 schedule insert 一致。
- 全部 created_at 相同（08:53:40）；id=1 的 completed_at（2026-09-03 00:00）早于这批 created_at，也早于 grok-output.md 文件时间（2026-09-06 08:59:04）。
- 两条 schedule 的 next_run_at 仍是 seed 值 1789488000 / 1788624000，没有被推进。
- 若周报写库或把 daily 展开，通常会新增约 30 条任务、改 status / next_run_at，或出现更晚的 created_at。当前快照没有这类痕迹。

判断：满足「只读，不改 tasks/schedules」。

## 文案核对

对照对象：grok-output.md vs expected.md vs 上表快照。不采信 Grok 自述。

grok-output.md 抽出的 id= 顺序：本周完成 1；仍未完成 4, 3, 2；未来 30 天 1, 6。任务集合为 {1,2,3,4,6}，另有 schedule id=1 英语学习。全文无 id=5，也无「已到期未推进」。

| 分节 | 文案行 | 对照 expected | 对照数据库 | 结果 |
|---|---|---|---|---|
| 本周完成 | id=1 本周完成稿（工作，优先级 1；完成于 2026-09-03） | 必须出现 id=1 本周完成稿 | id=1，title=本周完成稿，status=done，area=work，priority=1，completed_at=2026-09-03 | 通过 |
| 仍未完成 | id=2 今天待做（待做，学习，优先级 2） | 必须出现 id=2 今天待做 | id=2，title=今天待做，status=todo，area=study，priority=2，planned_at=当天 | 通过 |
| 仍未完成 | id=3 今天进行中（进行中，工作，优先级 1） | 必须出现 id=3 今天进行中 | id=3，title=今天进行中，status=doing，area=work，priority=1，planned_at=当天 | 通过 |
| 仍未完成 | id=4 逾期待做（待做，工作，优先级 1） | 必须出现 id=4 逾期待做 | id=4，title=逾期待做，status=todo，area=work，priority=1，planned_at=2026-09-03 | 通过 |
| 本周完成 / 仍未完成 | 无 id=5 | 不得把 id=5 今天跳过放进这两节 | id=5 title=今天跳过，status=skipped，planned_at=当天 | 通过 |
| 未来 30 天 | id=1 英语学习（daily，下次 2026-09-16） | 同一块：schedule id=1 英语学习一行 | schedule id=1 title=英语学习，frequency=daily，next_run_at=2026-09-16 | 通过 |
| 未来 30 天 | id=6 未来手工（工作，优先级 2，计划 2026-09-16） | 同一块：id=6 未来手工 | id=6 title=未来手工，area=work，priority=2，planned_at=2026-09-16，schedule_id=null | 通过 |
| 未来 30 天 | 无 schedule id=2 / 无「已到期未推进」 | 不得出现 schedule id=2 已到期未推进 | schedule id=2 next_run_at=今天 00:00，不在 [tomorrow, horizon) | 通过 |
| 每条 | 列出的任务/规则行均以 id=N 开头 | 每条带 id= | 文案 id 与库 id 对应；英语学习用的是 schedule id=1，不是 task id=1 | 通过 |

补充：

- 分节名称与 expected / skill 一致：本周完成、仍未完成、未来 30 天。
- 开场与统计「本周完成 1 件」「仍未完成 3 件（今天 2 件，逾期 1 件）」「未来 30 天：1 条重复规则 + 1 条手工任务」与库内应展示集合一致。
- 本周日期写成「2026-08-31 至 2026-09-06」，与 week_start / 业务日一致。
- 「逾期 3 天（原计划 2026-09-03）」按业务日 2026-09-06 相对 planned_at 计算正确：(1788624000-1788364800)/86400=3。
- 领域中文（工作/学习）与 area=work/study 一致；优先级与库字段一致。
- 未来 30 天写明「从明天 00:00 起 30 天，重复规则每个只一行，不按天展开」。文案只有 1 条 daily 规则，库内 tasks 仍是 6 行，没有 30 条展开实例。
- 开场写「跳过的不算完成，也不进仍未完成」「只投影、不生成任务」，与 id=5 未入账、行数未增加一致。expected 不要求点名 id=5，只要不放进完成/未完成即可。

## 问题列表

- 无。
