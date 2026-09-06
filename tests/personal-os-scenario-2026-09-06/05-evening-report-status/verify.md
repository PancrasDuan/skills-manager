# 独立验收 · 05-evening-report-status

- 职责：user-verifier
- 场景：05-evening-report-status
- 业务日：2026-09-06 Asia/Shanghai
- 核验时间：2026-09-06（独立只读验收，不信任 Grok 自述）
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.tasks / public.schedules
- 对照：command.md、expected.md、grok-output.md；未改库
- 结论：**PASS**

## 结论

PASS。当前库状态与晚报文案均符合 expected.md：今天完成必须出现 id=1 补做完成、id=2 当天完成；不得把 id=3/4 算进今天完成；今天之前未完成必须出现 id=6 逾期待做；不得出现 id=7 逾期跳过；id=5 今天跳过不算完成，文案已注明；每条任务行都带 id=。未见写库痕迹。

## DB 快照

查询时间点行数：

| 表 | 总行数 | is_deleted=false |
|---|---|---|
| public.tasks | 7 | 7 |
| public.schedules | 0 | 0 |

public.schedules 实测为空。

业务日边界：today_start=1788624000（2026-09-06 00:00:00 CST），tomorrow_start=1788710400（2026-09-07 00:00:00 CST）。

### public.tasks

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | completed_at | completed_at(Asia/Shanghai) | is_deleted | 按 expected 归类 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 补做完成 | study | done | 2 | 1788537600 | 2026-09-05 00:00:00 | 1788652800 | 2026-09-06 08:00:00 | false | 今天完成（补做） |
| 2 | 当天完成 | work | done | 1 | 1788624000 | 2026-09-06 00:00:00 | 1788652860 | 2026-09-06 08:01:00 | false | 今天完成 |
| 3 | 今天还没做 | work | todo | 1 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 不得算进今天完成 |
| 4 | 今天进行中 | study | doing | 2 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 不得算进今天完成 |
| 5 | 今天跳过 | life | skipped | 3 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 今天跳过，不算完成 |
| 6 | 逾期待做 | work | todo | 1 | 1788364800 | 2026-09-03 00:00:00 | null |  | false | 今天之前未完成 |
| 7 | 逾期跳过 | life | skipped | 3 | 1788364800 | 2026-09-03 00:00:00 | null |  | false | 不得出现 |

补充：7 行 due_at=null、schedule_id=null、created_at=1788655407（2026-09-06 08:43:27 Asia/Shanghai）。

关键字段解读：

- 今天完成按 completed_at 落在 [today_start, tomorrow_start) 且 status=done：id=1 completed_at=08:00、id=2 completed_at=08:01。id=1 的 planned_at 是昨天，属于补做；id=2 的 planned_at 是当天。
- 今天之前未完成按 planned_at < today_start 且 status in (todo, doing)：只有 id=6。相对业务日逾期 3 天。
- 今天跳过：id=5 status=skipped，planned_at 当天，不算完成。
- 必须排除：id=3 当天 todo、id=4 当天 doing（不算今天完成，也不进今天之前未完成）；id=7 逾期 skipped（不算待做，晚报不得出现）。

### 只读约束

验收会话只跑 SELECT，未执行 INSERT/UPDATE/DELETE/DDL。

- 行数仍是 tasks=7 / schedules=0，与 seed.sql 的 7 条 insert 一致。
- 7 条 tasks 的 created_at 相同；id=1/2 的 completed_at（08:00 / 08:01）早于这批 created_at（08:43:27），也早于 grok-output.md 文件时间（08:47:01）。
- 若晚报写库，通常会改 status、改 completed_at，或出现更晚的 created_at。当前快照没有这类痕迹。

判断：满足「只读，不改 tasks/schedules」。

## 文案核对

对照对象：grok-output.md vs expected.md vs 上表快照。不采信 Grok 自述。

grok-output.md 抽出的 id= 顺序：1, 2, 6, 5。集合为 {1,2,5,6}。

| 分节 | 文案行 | 对照 expected | 对照数据库 | 结果 |
|---|---|---|---|---|
| 今天完成 | id=1 补做完成（学习，优先级 2；补做，原计划 2026-09-05） | 必须出现 id=1 补做完成 | id=1，title=补做完成，status=done，area=study，priority=2，planned_at=昨天，completed_at=今天 08:00 | 通过 |
| 今天完成 | id=2 当天完成（工作，优先级 1） | 必须出现 id=2 当天完成 | id=2，title=当天完成，status=done，area=work，priority=1，planned_at=当天，completed_at=今天 08:01 | 通过 |
| 今天完成 | 无 id=3 / id=4 | 不得把 id=3/4 算进今天完成 | id=3 status=todo、id=4 status=doing，planned_at 都是当天，completed_at 为空 | 通过 |
| 今天之前未完成 | id=6 逾期待做（待做，工作，优先级 1） | 必须出现 id=6 逾期待做 | id=6，title=逾期待做，status=todo，area=work，priority=1，planned_at=2026-09-03 | 通过 |
| 全文 | 无 id=7 | 不得出现 id=7 逾期跳过 | id=7 title=逾期跳过，status=skipped，planned_at=2026-09-03 | 通过 |
| 完成情况 | id=5 已跳过，不算完成 | id=5 今天跳过不算完成，文案可注明 | id=5 title=今天跳过，status=skipped，planned_at=当天；未进入「今天完成」 | 通过 |
| 每条 | 列出的任务行均以 id=N 开头 | 每条带 id= | 文案 id 与库 id 对应 | 通过 |

补充：

- 分节名称与 expected / skill 一致：今天完成、今天之前未完成。
- 开场与完成情况「今天完成 2 件，其中 1 件是补做」「今天之前未完成 1 件」「跳过的不算完成」与库内应展示集合一致。
- 「逾期 3 天（原计划 2026-09-03）」按业务日 2026-09-06 相对 planned_at 计算正确。
- 领域中文（学习/工作）与 area=study/work 一致；优先级与库字段一致。
- id=1 标明「补做，原计划 2026-09-05」；id=2 未标补做。符合 completed_at 今天、planned_at 昨天/当天的区分。

## 问题列表

- 无。
