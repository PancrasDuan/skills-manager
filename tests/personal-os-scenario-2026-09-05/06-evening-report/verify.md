# 验收报告 · 06-evening-report

- 结论：PASS
- 职责：user-verifier
- 业务日：2026-09-05 Asia/Shanghai
- 核验方式：只读 command.md / expected.md / grok-output.md；Supabase execute_sql 查询 public.tasks、public.schedules（project_id=zvdcjzjfhkjasikchceo）；未改库。
- 核验时间：2026-09-05 15:39–15:41 UTC（约 23:39–23:41 Asia/Shanghai）

## DB 快照

- 查询工具：Supabase MCP execute_sql
- project_id：zvdcjzjfhkjasikchceo
- 数据库时区：UTC
- 行数：public.tasks = 3，public.schedules = 1；软删均为 0
- 快照指纹（只读聚合 md5）：9089afca34dbc6feac2417b33e467e72

### 表结构（information_schema）

| 表 | 列 | 类型 | 可空 |
| --- | --- | --- | --- |
| tasks | id | bigint | NO |
| tasks | title | text | NO |
| tasks | area | text | NO |
| tasks | status | text | NO |
| tasks | priority | smallint | NO |
| tasks | planned_at | bigint | NO |
| tasks | due_at | bigint | YES |
| tasks | schedule_id | bigint | YES |
| tasks | created_at | bigint | NO |
| tasks | completed_at | bigint | YES |
| tasks | is_deleted | boolean | NO |
| schedules | id | bigint | NO |
| schedules | title | text | NO |
| schedules | frequency | text | NO |
| schedules | schedule | jsonb | NO |
| schedules | task_template | jsonb | NO |
| schedules | active | boolean | NO |
| schedules | created_at | bigint | NO |
| schedules | is_deleted | boolean | NO |
| schedules | next_run_at | bigint | YES |

时间字段按 Unix 秒解释，展示时换算为 Asia/Shanghai。

### public.tasks

| id | title | area | status | priority | planned_at | planned_shanghai | completed_at | completed_shanghai | due_at | schedule_id | created_at | created_shanghai | is_deleted |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | study | done | 2 | 1788451200 | 2026-09-04 00:00:00 | 1788619500 | 2026-09-05 22:45:00 | null | 1 | 1788622317 | 2026-09-05 23:31:57 | false |
| 2 | 整理 Personal OS 文档 | work | todo | 1 | 1788364800 | 2026-09-03 00:00:00 | null | null | null | null | 1788622317 | 2026-09-05 23:31:57 | false |
| 3 | 跳过的运动 | life | skipped | 3 | 1788537600 | 2026-09-05 00:00:00 | null | null | null | null | 1788622317 | 2026-09-05 23:31:57 | false |

### public.schedules

| id | title | frequency | schedule | task_template | active | next_run_at | next_run_shanghai | created_at | created_shanghai | is_deleted |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | daily | {} | {"area":"study","priority":2} | true | 1788624000 | 2026-09-06 00:00:00 | 1788622317 | 2026-09-05 23:31:57 | false |

### 相对业务日 2026-09-05 的字段判定

| expected 条件 | DB 证据 | 结果 |
| --- | --- | --- |
| 今天完成包含「英语学习」（补做：planned_at 昨天，completed_at 今天） | id=1，status=done，planned_at=2026-09-04，completed_at=2026-09-05 22:45:00 | 符合 |
| 今天之前未完成包含「整理 Personal OS 文档」 | id=2，status=todo，planned_at=2026-09-03，completed_at 为空 | 符合 |
| 「跳过的运动」不算完成 | id=3，status=skipped，completed_at 为空，planned_at=今天 | 符合 |
| 只读，数据不变 | 本验收只执行 SELECT；三条任务 status/时间戳仍符合上述语义；completed_at（22:45）早于 created_at（23:31:57）和 grok-output.md 写入时间（23:36），不支持晚报运行时写库 | 符合 |

## 文案核对

对照对象：grok-output.md（晚报） vs expected.md vs 上表。

| expected / DB 事实 | grok-output.md | 结果 |
| --- | --- | --- |
| 今天完成包含「英语学习」，且为补做 | 「今天完成」列出「英语学习（学习，优先级 2；补做，原计划 2026-09-04）」 | 符合 |
| planned_at 昨天、completed_at 今天 | 原计划 2026-09-04；完成情况计为今天完成 1 件，其中 1 件补做 | 符合 |
| area=study、priority=2 | 「学习，优先级 2」 | 符合 |
| 今天之前未完成包含「整理 Personal OS 文档」 | 「今天之前未完成」列出该标题；完成情况「今天之前未完成 1 件」 | 符合 |
| planned_at=2026-09-03、status=todo | 「逾期 2 天（原计划 2026-09-03）」；2026-09-05 相对 2026-09-03 为 2 天 | 符合 |
| area=work、priority=1 | 「工作，优先级 1」 | 符合 |
| 「跳过的运动」不算完成 | 未进入「今天完成」；完成情况写「已跳过，不算完成」 | 符合 |
| 只读，不改安排 | 文案写「未改动安排」；DB 中文档仍为 todo、跳过仍为 skipped、英语学习完成时间未落在晚报写入时刻 | 符合 |

摘要句「今天实际完成 1 件事，其中 1 件是补做；另外还有 1 件今天之前没做完。跳过的不算完成。」与当前库内三条任务的分类一致。

## 问题列表

- 无。当前库字段与晚报文案均满足 expected.md。
