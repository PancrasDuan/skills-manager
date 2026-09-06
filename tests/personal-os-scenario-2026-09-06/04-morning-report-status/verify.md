# 独立验收 · 04-morning-report-status

- 职责：user-verifier
- 场景：04-morning-report-status
- 业务日：2026-09-06 Asia/Shanghai
- 核验时间：2026-09-06（独立只读验收，不信任 Grok 自述）
- 查询：Supabase execute_sql，project_id=zvdcjzjfhkjasikchceo，只读 public.tasks / public.schedules
- 对照：command.md、expected.md、grok-output.md；未改库
- 结论：**PASS**

## 结论

PASS。当前库状态与早报文案均符合 expected.md：今天待做必须出现 id=1、id=2；今天已跳过必须出现 id=4；今天之前未完成必须出现 id=6、id=7；不得出现 id=3/5/8/9；每条任务行都带 `id=`。未见写库痕迹。

## DB 快照

查询时间点行数：

| 表 | 总行数 | is_deleted=false |
|---|---|---|
| public.tasks | 9 | 8 |
| public.schedules | 0 | 0 |

`public.schedules` 实测 `[]`。

### public.tasks

| id | title | area | status | priority | planned_at | planned_at(Asia/Shanghai) | completed_at | completed_at(Asia/Shanghai) | is_deleted | 按 expected 归类 |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 今天待做 | study | todo | 2 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 今天待做 |
| 2 | 今天进行中 | work | doing | 1 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 今天待做 |
| 3 | 今天已完成 | work | done | 1 | 1788624000 | 2026-09-06 00:00:00 | 1788652800 | 2026-09-06 08:00:00 | false | 不得出现 |
| 4 | 今天已跳过 | life | skipped | 3 | 1788624000 | 2026-09-06 00:00:00 | null |  | false | 今天已跳过 |
| 5 | 今天已删除 | life | todo | 3 | 1788624000 | 2026-09-06 00:00:00 | null |  | true | 不得出现 |
| 6 | 逾期待做 | work | todo | 1 | 1788364800 | 2026-09-03 00:00:00 | null |  | false | 今天之前未完成 |
| 7 | 逾期进行中 | study | doing | 2 | 1788537600 | 2026-09-05 00:00:00 | null |  | false | 今天之前未完成 |
| 8 | 逾期已完成 | work | done | 2 | 1788364800 | 2026-09-03 00:00:00 | 1788368400 | 2026-09-03 01:00:00 | false | 不得出现 |
| 9 | 逾期已跳过 | life | skipped | 3 | 1788364800 | 2026-09-03 00:00:00 | null |  | false | 不得出现 |

补充：9 行 `due_at=null`、`schedule_id=null`、`created_at=1788654696`（2026-09-06 08:31:36 Asia/Shanghai）。

关键字段解读：

- 业务日 2026-09-06 的未完成：id=1 status=todo、id=2 status=doing，planned_at 都落在当天 00:00 CST。
- 今天已跳过：id=4 status=skipped，planned_at 当天，is_deleted=false。
- 今天之前未完成：id=6 planned_at=2026-09-03、status=todo；id=7 planned_at=2026-09-05、status=doing。相对业务日分别逾期 3 天、1 天。
- 必须隐藏：id=3 当天已完成、id=5 当天已删除、id=8 逾期已完成、id=9 逾期已跳过。

### 只读约束

验收会话只跑 SELECT / list_tables，未执行 INSERT/UPDATE/DELETE/DDL。

- 行数仍是 tasks=9 / schedules=0。
- 9 条 tasks 的 created_at 相同；id=3/8 的 completed_at 早于或等于这批 created_at，不像报告执行时新写。
- 若早报写库，通常会新增行、改 status、改 planned_at，或出现更晚的 created_at。当前快照没有这类痕迹。

判断：满足「只读，不改 tasks/schedules」。

## 文案核对

对照对象：grok-output.md vs expected.md vs 上表快照。不采信 Grok 自述。

grok-output.md 抽出的 `id=` 顺序：`2, 1, 6, 7, 4`。集合为 `{1,2,4,6,7}`。

| 分节 | 文案行 | 对照 expected | 对照数据库 | 结果 |
|---|---|---|---|---|
| 今天待做 | `id=2 今天进行中（进行中，工作，优先级 1）` | 必须出现 id=2 今天进行中 | id=2，title=今天进行中，status=doing，area=work，priority=1，planned_at=当天 | 通过 |
| 今天待做 | `id=1 今天待做（待做，学习，优先级 2）` | 必须出现 id=1 今天待做 | id=1，title=今天待做，status=todo，area=study，priority=2，planned_at=当天 | 通过 |
| 今天已跳过 | `id=4 今天已跳过（生活，优先级 3）` | 必须出现 id=4 今天已跳过 | id=4，title=今天已跳过，status=skipped，area=life，priority=3，planned_at=当天 | 通过 |
| 今天之前未完成 | `id=6 逾期待做（待做，工作，优先级 1）` | 必须出现 id=6 逾期待做 | id=6，title=逾期待做，status=todo，area=work，priority=1，planned_at=2026-09-03 | 通过 |
| 今天之前未完成 | `id=7 逾期进行中（进行中，学习，优先级 2）` | 必须出现 id=7 逾期进行中 | id=7，title=逾期进行中，status=doing，area=study，priority=2，planned_at=2026-09-05 | 通过 |
| 全文 | 无 `id=3` / `id=5` / `id=8` / `id=9` | 不得出现 id=3/5/8/9 | id=3 done、id=5 is_deleted=true、id=8 done、id=9 skipped | 通过 |
| 每条 | 5 条任务行均以 `- id=N` 开头 | 每条带 id= | 文案 id 与库 id 一一对应 | 通过 |

补充：

- 分节名称与 expected 一致：`今天待做`、`今天已跳过`、`今天之前未完成`。
- 开场计数「今天有 2 件待做（含进行中）」「2 件今天之前没做完」「1 件已跳过」与库内应展示集合一致。
- 「逾期 3 天（原计划 2026-09-03）」「逾期 1 天（原计划 2026-09-05）」按业务日 2026-09-06 相对 planned_at 计算正确。
- 领域中文（学习/工作/生活）与 area=study/work/life 一致；优先级与库字段一致。
- 今天待做内部顺序是 id=2 再 id=1（优先级 1 在前）。expected 只要求两条都出现，不规定顺序。

## 问题列表

- 无。
