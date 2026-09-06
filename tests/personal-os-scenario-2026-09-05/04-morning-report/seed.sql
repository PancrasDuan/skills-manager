insert into schedules (title, frequency, schedule, task_template, active, is_deleted, next_run_at)
values ('英语学习', 'daily', '{}'::jsonb, '{"area":"study","priority":2}'::jsonb, true, false, 1788624000);
insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, is_deleted)
values
  ('英语学习', 'study', 'todo', 2, 1788537600, null, 1, false),
  ('整理 Personal OS 文档', 'work', 'todo', 1, 1788364800, 1788451200, null, false);
