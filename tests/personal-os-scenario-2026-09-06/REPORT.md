# Personal OS v2.1 扩充场景验证报告

- 业务日：2026-09-06 周日 Asia/Shanghai（ISO weekday=7）
- 项目：Supabase `personal_os` / `zvdcjzjfhkjasikchceo`
- 相对上一轮：交互和文案一律 `id=N`；补全 frequency 命中矩阵；补全早/晚/周报各 status
- 结论：**8 / 8 PASS**

目录：`/Users/pancras/Code/personal/codex/skills-manager/tests/personal-os-scenario-2026-09-06/`

## 方法

每场独立：truncate + seed → grok-bot 子 agent → user-verifier 子 agent。`fork_context=false`。交互只走文档。

## 总表

| 场景 | grok-bot | user-verifier | 结论 |
|---|---|---|---|
| 01 新建 daily/weekly/monthly | Locke `01a07405-7fa4-73c2-b82b-b9dd5d9a4a5e` | Hilbert `01a0740d-8a81-7bf0-a29a-9bc9e5955522` | PASS |
| 02 五种 frequency 命中/不命中 | Huygens `01a0740f-d3f6-74d3-a3ef-fbf738a76946` | Godel `01a07415-7354-7a10-ae16-c7d1736735b1` | PASS |
| 03 按 id 流转 todo/doing/done/skipped | Copernicus `01a07419-087a-78b2-9543-c23bc934777b` | Harvey `01a0741b-3853-7013-b4e1-7a8b30940520` | PASS |
| 04 早报各 status | Cicero `01a07420-b6f7-7233-8115-500977df9d6d` | Banach `01a07426-6862-7b13-9164-7fe5b79fb75f` | PASS |
| 05 晚报各 status | Kant `01a0742b-a068-73e0-ac01-dc5c4c53ea17` | Mill `01a0742f-2069-7d72-9916-79cfa4dc9b14` | PASS |
| 06 周报含今天 + 未来30天 | McClintock `01a07434-e8c0-7643-a711-f5222702be6e` | Ptolemy `01a0743a-d183-7df0-bac8-d935907fb971` | PASS |
| 07 按 id 删规则不级联 | Raman `01a07442-f973-7c00-a357-efd60fd62d7c` | Zeno `01a07451-487d-7020-8b57-18b7614b8ca1` | PASS |
| 08 id=1 今天生效 | Kuhn `01a07455-36e5-73e0-87f1-d4ebfff37c30` | James `01a07459-9830-7be2-af4e-f2ad2a52e16c` | PASS |

## 分场景与执行后 DB

### 01 新建三条频率

- grok-bot Locke：建 daily / weekly(周日) / monthly(6号)，文案三条都有 `id=`
- 执行后 DB：3 条 schedules，0 条 tasks
  - id=1 daily，next_run_at=2026-09-07
  - id=2 weekly weekday=7，next_run_at=2026-09-13
  - id=3 monthly day=6，next_run_at=2026-10-06

### 02 生成矩阵（本场覆盖 frequency）

- grok-bot Huygens 一次「生成今天」处理 9 条规则
- 今天生成 6 条 todo（planned_at=2026-09-06），无昨天回补
- 命中并生成：id=1 daily、id=2 weekly日、id=4 monthly 6号、id=6 quarterly 季末、id=7 yearly 生日、id=9 过期周日游标
- 不生成：id=3 weekly一（推到 09-07）、id=5 monthly 15号（推到 09-15）、id=8 明天才开始的 daily（游标不动）
- 文案 9 条都带 `id=`

### 03 按 id 改状态

- 用户指令：`id=1 已完成。id=2 开始做。id=3 跳过。`
- 执行后：id=1 done+completed_at 当天；id=2 doing；id=3 skipped。文案是 `id=1 已完成` 形式，不用标题当主键

### 04 早报 status

- 待做：id=1 todo、id=2 doing
- 已跳过：id=4
- 逾期未完成：id=6 todo、id=7 doing
- 不出现：id=3 done、id=5 deleted、id=8 逾期 done、id=9 逾期 skipped

### 05 晚报 status

- 今天完成：id=1 补做、id=2 当天完成
- 未把 id=3/4 算完成
- 逾期未完成：id=6
- id=5 跳过不算完成；id=7 逾期跳过不出现

### 06 周报

- 本周完成 id=1；仍未完成含今天 id=2/3 和逾期 id=4
- id=5 skipped 不进完成也不进未完成
- 未来 30 天同一块：schedule id=1 + 手工 id=6；到期未推进的 schedule id=2 不出现

### 07 删规则

- schedules id=1 is_deleted=true，行还在
- tasks id=1 is_deleted=false，schedule_id=1
- 文案：`id=1 已删除`，任务 id=1 保留

### 08 今天生效

- 规则原本 next_run_at=明天；`id=1 今天生效` 后生成今天任务
- tasks id=1，schedule_id=1，planned_at=2026-09-06，todo
- schedules id=1 next_run_at 仍/回到 2026-09-07

## 已覆盖、仍未做

已覆盖：id 交互与输出；daily/weekly/monthly/quarterly/yearly 命中与不命中；过期游标不回补；todo/doing/done/skipped/deleted 在三份报告中的出现规则；按 id 完成/进行中/跳过/删除/今天生效。

未做：幂等连跑、并发死锁、权限攻防。

## 收尾数据

停在 08：1 条 daily「英语学习」规则（下次明天）+ 1 条今天 todo 任务。
