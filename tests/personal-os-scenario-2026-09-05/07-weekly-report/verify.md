# 验收报告 · 07-weekly-report

- 结论：**PASS**
- 职责：user-verifier
- 业务日：2026-09-05 Asia/Shanghai
- 项目：`zvdcjzjfhkjasikchceo`
- 查询：Supabase `execute_sql` 只读 `public.tasks`、`public.schedules`
- 对照：`expected.md` + `grok-output.md`
- 本验收未写库

## DB 快照

查询时间：验收当时。时间戳用 `to_timestamp(...) AT TIME ZONE 'Asia/Shanghai'`。

行数：`tasks=4`，`schedules=2`。全部 `is_deleted=false`。未发现 daily 展开后的 30 条任务。

### public.tasks

| id | title | area | status | priority | planned_at / 上海日期 | completed_at / 上海日期 | schedule_id |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 本周已完成的文档 | work | done | 1 | 1788105600 / 2026-08-31 00:00:00 | 1788364800 / 2026-09-03 00:00:00 | null |
| 2 | 今天还没做的英语 | study | todo | 2 | 1788537600 / 2026-09-05 00:00:00 | null | 1 |
| 3 | 逾期的整理 | work | todo | 1 | 1788364800 / 2026-09-03 00:00:00 | null | null |
| 4 | 下周五手工任务 | work | todo | 2 | 1789401600 / 2026-09-15 00:00:00 | null | null |

四条 `created_at` 均为 `1788623166`（2026-09-05 23:46:06）。

### public.schedules

| id | title | frequency | active | next_run_at / 上海日期 | task_template |
| --- | --- | --- | --- | --- | --- |
| 1 | 英语学习 | daily | true | 1789401600 / 2026-09-15 00:00:00 | area=study, priority=2 |
| 2 | 已到期未推进 | daily | true | 1788537600 / 2026-09-05 00:00:00 | area=life, priority=3 |

ISO 周：2026-08-31 至 2026-09-06。业务日是周六。

只读一致性：当前字段与 `expected.md` 的种子语义一致（完成 1、今天未完成 1、逾期 1、未来手工 1；英语学习下次 2026-09-15；已到期未推进 next_run_at=今天）。没有多出来的 daily 实例，也没有状态被改成 done/deleted。本验收只执行 SELECT。

## 文案核对

对照 `grok-output.md`，不采信 Grok 自述。

| 期望 | DB 依据 | 文案 | 结果 |
| --- | --- | --- | --- |
| 本周完成包含「本周已完成的文档」 | task#1 status=done，completed_at=2026-09-03 | 「本周已完成的文档（工作，优先级 1；完成于 2026-09-03）」 | 通过 |
| 仍未完成包含今天的「今天还没做的英语」 | task#2 status=todo，planned_at=今天 | 「仍未完成」下「今天（2026-09-05）」列出该条 | 通过 |
| 仍未完成包含逾期的「逾期的整理」 | task#3 status=todo，planned_at=2026-09-03，距业务日 2 天 | 「逾期 2 天（原计划 2026-09-03）」列出该条 | 通过 |
| 未来 30 天合成一块：英语学习（next_run_at=2026-09-15）一行 + 手工「下周五手工任务」逐条 | schedule#1 next_run_at=2026-09-15；task#4 planned_at=2026-09-15 | 同一节「未来 30 天」两行：规则一行、手工一条 | 通过 |
| 「已到期未推进」next_run_at=今天，不应出现在未来 30 天 | schedule#2 next_run_at=2026-09-05 00:00:00 | 未来 30 天未出现该标题；窗口写成「从明天 00:00 起」 | 通过 |
| daily 不要展开成 30 条 | schedules 仅 2 行 daily；tasks 仍 4 行 | 「英语学习（daily，下次 2026-09-15）」一行；统计「1 条重复规则 + 1 条手工任务」 | 通过 |
| 只读，数据不变 | 见快照 | 「只投影、不生成任务」与库内行数/状态一致 | 通过 |

重点四项：

1. 仍未完成包含今天任务：是。
2. 未来 30 天把 schedule（next_run_at）和手工任务写在同一块：是。
3. 「已到期未推进」未进入未来 30 天：是。
4. daily 未展开成 30 条：是。

## 问题列表

无。当前库字段与周报文案均满足 `expected.md`。
