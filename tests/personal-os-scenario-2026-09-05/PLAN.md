# Personal OS v2.1 场景验证计划

业务日：`2026-09-05`（Asia/Shanghai）
- today_start = `1788537600`（2026-09-05 00:00）
- tomorrow_start = `1788624000`（2026-09-06 00:00）
- yesterday = `1788451200`（2026-09-04 00:00）
- week_start = `1788105600`（2026-08-31 周一 00:00）
- next_week_start = `1788710400`（2026-09-07 00:00）
- horizon_start = `1791216000`（2026-10-06 00:00，明天起 30 天）
- in_30d = `1789401600`（2026-09-15 00:00）
- overdue_day = `1788364800`（2026-09-03 00:00）

项目：Supabase `personal_os` / `zvdcjzjfhkjasikchceo`

角色：
- 主 agent：清库、写命令文档、部署种子数据、调度子 agent、汇总报告
- grok-bot 子 agent：每个场景独立，只读该场景 `command.md` + 指定 skill，执行后写 `grok-output.md`
- user-verifier 子 agent：每个场景独立，只读文档 + 查库，写 `verify.md`，不改库

交互只走文档，不在对话里传递场景细节。

场景（相互独立，每场先清库再种子）：
1. `01-ops-create-daily-schedule`：新建 daily，默认明天生效
2. `02-generate-today-cursor-not-due`：游标在明天，生成今天应跳过
3. `03-generate-today-due`：游标在今天，生成并推进游标
4. `04-morning-report`：早报只读，含今天待做和逾期
5. `05-ops-complete-task`：标完成并写 completed_at
6. `06-evening-report`：晚报按 completed_at，含补做
7. `07-weekly-report`：仍未完成含今天；未来 30 天 next_run_at + 手工合成
8. `08-delete-schedule-keep-tasks`：逻辑删 schedule，不级联任务
