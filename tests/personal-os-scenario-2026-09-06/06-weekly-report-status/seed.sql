insert into schedules (title, frequency, schedule, task_template, active, is_deleted, next_run_at) values
('英语学习', 'daily', '{}'::jsonb, '{"area":"study","priority":2}'::jsonb, true, false, 1789488000),
('已到期未推进', 'daily', '{}'::jsonb, '{"area":"life","priority":3}'::jsonb, true, false, 1788624000);
insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, completed_at, is_deleted) values
('本周完成稿', 'work', 'done', 1, 1788105600, null, null, 1788364800, false),
('今天待做', 'study', 'todo', 2, 1788624000, null, 1, null, false),
('今天进行中', 'work', 'doing', 1, 1788624000, null, null, null, false),
('逾期待做', 'work', 'todo', 1, 1788364800, null, null, null, false),
('今天跳过', 'life', 'skipped', 3, 1788624000, null, null, null, false),
('未来手工', 'work', 'todo', 2, 1789488000, null, null, null, false);
