insert into schedules (title, frequency, schedule, task_template, active, is_deleted, next_run_at) values
('英语学习', 'daily', '{}'::jsonb, '{"area":"study","priority":2}'::jsonb, true, false, 1788710400);
insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, is_deleted) values
('英语学习', 'study', 'todo', 2, 1788624000, null, 1, false);
