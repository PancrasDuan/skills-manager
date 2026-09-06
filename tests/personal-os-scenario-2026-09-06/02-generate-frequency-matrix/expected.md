# 期望

今天应生成（各 1 条 today todo，planned_at=1788624000）：
- id=1 每天英语，next_run_at 变为 1788710400
- id=2 每周日复盘，next_run_at 变为 1789228800
- id=4 每月6号账单，next_run_at 变为 1791216000
- id=6 每季末体检，next_run_at 变为 1796486400
- id=7 每年生日，next_run_at 变为 1820160000
- id=9 过期游标的周日：补游标但不补昨天任务，今天生成 1 条，next_run_at=1789228800

今天不应生成：
- id=3 每周一站会：不命中，无 task，next_run_at 推到 1788710400
- id=5 每月15号回顾：不命中，无 task，next_run_at 推到 1789401600
- id=8 明天才开始的每日：跳过且 next_run_at 仍为 1788710400

tasks 总数=6，全部 planned_at=1788624000，没有 yesterday 的回补行。
文案用 id= 说明新增/跳过/下次，不要只写标题。
