insert into schedules (title, frequency, schedule, task_template, active, is_deleted, next_run_at)
values
  ('英语学习', 'daily', '{}'::jsonb, '{"area":"study","priority":2}'::jsonb, true, false, 1789401600),
  ('已到期未推进', 'daily', '{}'::jsonb, '{"area":"life","priority":3}'::jsonb, true, false, 1788537600);
insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, completed_at, is_deleted)
values
  ('本周已完成的文档', 'work', 'done', 1, 1788105600, null, null, 1788364800, false),
  ('今天还没做的英语', 'study', 'todo', 2, 1788537600, null, 1, null, false),
  ('逾期的整理', 'work', 'todo', 1, 1788364800, null, null, null, false),
  ('下周五手工任务', 'work', 'todo', 2, 1789401600, null, null, null, false);
