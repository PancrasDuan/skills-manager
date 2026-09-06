# Personal OS v2.1 场景验证报告

- 业务日：2026-09-05 Asia/Shanghai
- 项目：Supabase `personal_os` / `zvdcjzjfhkjasikchceo`
- 类型：整体场景验证（不做幂等、攻防、死锁）
- 主 agent：清库、写命令、部署种子、调度独立子 agent、汇总本报告
- 交互方式：全部落在本目录文档，不在对话里传递场景细节
- 结论：**8 / 8 PASS**

目录：`/Users/pancras/Code/personal/codex/skills-manager/tests/personal-os-scenario-2026-09-05/`

## 方法

每个场景相互独立：先 `truncate ... restart identity`，再按 `seed.sql` 部署，然后新开两个子 agent（`fork_context=false`）。

| 角色 | 职责 | 输入 | 输出 |
|---|---|---|---|
| grok-bot | 模拟正式 Grok Bot，只读该场景 command.md + 指定 skill，对库执行业务 | command.md, SKILL.md | grok-output.md（给用户看的文案） |
| user-verifier | 模拟用户核对，不信任 Grok 自述，只读查库 | command.md, expected.md, grok-output.md | verify.md |

## 总表

| 场景 | grok-bot | user-verifier | 结论 |
|---|---|---|---|
| 01 新建 daily，默认明天生效 | Hubble `01a0720c-d36a-7ef2-9601-32882b9388a7` | Euclid `01a07210-d2a2-74a2-8f0f-2a5973ba8001` | PASS |
| 02 游标在明天，生成今天跳过 | Schrodinger `01a07213-f61b-7da1-9387-77972a03b6e2` | Dirac `01a07216-25e9-7b70-a2ad-13f24a643b8b` | PASS |
| 03 游标在今天，生成并推进 | Curie `01a07219-e313-7ab0-bce9-adba794c5cc2` | Hypatia `01a07220-b122-7b01-8d14-b34f22ef38fc` | PASS |
| 04 早报只读 | Lovelace `01a07223-bfd4-71a2-8ccb-03876d3b42c7` | Descartes `01a07226-f2d6-7c80-9818-de681bcfd25b` | PASS |
| 05 标完成 | Sagan `01a0722a-9c47-7101-8642-6508d5f0c829` | Turing `01a0722e-8753-7461-b7ae-851c612b0d40` | PASS |
| 06 晚报含补做 | Euler `01a07232-aafb-7353-86d2-385b22c56a78` | Confucius `01a07237-272d-7d10-ba9e-99995c100fc3` | PASS |
| 07 周报：未完成含今天，未来 30 天合成 | Franklin `01a0723f-b266-7541-a10f-e095be38a766` | Aristotle `01a07243-a2bf-7701-a034-0b90b4fe60e0` | PASS |
| 08 逻辑删 schedule，不级联任务 | Linnaeus `01a07248-e085-7502-9811-73ce5763d3c6` | Ohm `01a0724b-1ada-7611-bae3-fbdbcd7fdfec` | PASS |

## 分场景

### 01 新建 daily，默认明天生效

- skill：`personal-os-ops`
- 种子：空库
- grok-bot Hubble：建「英语学习」daily，文案写明天生效、今天不生成
- 执行后 DB：`schedules` 1 行，`next_run_at=1788624000`（2026-09-06）；`tasks` 0 行
- user-verifier Euclid：PASS

### 02 游标未到，生成今天跳过

- skill：`personal-os-generate-today`
- 种子：daily，`next_run_at=明天`
- grok-bot Schrodinger：跳过「英语学习」，说明游标未到，未推进
- 执行后 DB：`tasks` 仍 0；`next_run_at` 仍 `1788624000`
- user-verifier Dirac：PASS

### 03 游标到期，生成并推进

- skill：`personal-os-generate-today`
- 种子：daily，`next_run_at=今天`
- grok-bot Curie：新增今天「英语学习」，游标推到明天
- 执行后 DB：`tasks` 1 行，`planned_at=1788537600`，`status=todo`，`schedule_id=1`，`due_at=null`；`next_run_at=1788624000`
- user-verifier Hypatia：PASS

### 04 早报

- skill：`personal-os-report`
- 种子：今天 todo「英语学习」+ 逾期「整理 Personal OS 文档」
- grok-bot Lovelace：早报列出今天待做 1、逾期 1，无未来 30 天
- 执行后 DB：仍 `tasks=2` / `schedules=1`，只读未写
- user-verifier Descartes：PASS

### 05 标完成

- skill：`personal-os-ops`
- 种子：今天 todo「英语学习」
- grok-bot Sagan：记为完成，计划日期未改
- 执行后 DB：`status=done`，`completed_at=1788621990`（当天），`planned_at` 仍 `1788537600`
- user-verifier Turing：PASS

### 06 晚报

- skill：`personal-os-report`
- 种子：补做完成「英语学习」、逾期文档、skipped 运动
- grok-bot Euler：今天完成含补做；逾期单独列出；跳过不算完成
- 执行后 DB：3 条任务状态未变，只读
- user-verifier Confucius：PASS

### 07 周报

- skill：`personal-os-report`
- 种子：本周完成 1、今天未完成 1、逾期 1、未来手工 1；schedule 下次 09-15；另一条 next_run_at=今天
- grok-bot Franklin：仍未完成含今天；未来 30 天同一块写「英语学习」一行 + 手工任务；「已到期未推进」未进入未来；daily 未展开
- 执行后 DB：`tasks=4` / `schedules=2`，只读
- user-verifier Aristotle：PASS

### 08 删规则留任务

- skill：`personal-os-ops`
- 种子：live schedule + 已生成 task
- grok-bot Linnaeus：逻辑删除规则，任务保留
- 执行后 DB：`schedules.is_deleted=true` 且行仍在；`tasks.is_deleted=false`，`schedule_id=1`，`status=todo`
- user-verifier Ohm：PASS

## 场景覆盖到的规则

已覆盖：新建 schedule 明天生效、游标不到不生成、到期生成并推进 `next_run_at`、早报只读、完成写 `completed_at` 不改 `planned_at`、晚报按完成时间含补做、skipped 不算完成、周报未完成含今天、未来 30 天用 `next_run_at` 一行且与手工任务合成、到期游标不进未来 30 天、逻辑删 schedule 不级联。

未做（按计划排除）：幂等连跑、并发死锁、权限攻防、物理删除防护压测。

## 库收尾

最后一场留下的数据即 08 的结果：1 条已逻辑删除的「英语学习」规则 + 1 条仍活的「英语学习」任务。如需空白库，可再 truncate。
