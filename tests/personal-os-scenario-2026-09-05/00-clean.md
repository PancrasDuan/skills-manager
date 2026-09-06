# 清库

主 agent 已执行：

```sql
truncate table public.tasks, public.schedules restart identity;
```

结果：tasks=0，schedules=0。后续每场场景开始前都会再 truncate + 按 seed.sql 部署。
