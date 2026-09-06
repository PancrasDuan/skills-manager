insert into schedules (title, frequency, schedule, task_template, active, is_deleted, next_run_at) values
('每天英语', 'daily', '{}'::jsonb, '{"area":"study","priority":2}'::jsonb, true, false, 1788624000),
('每周日复盘', 'weekly', '{"weekday":7}'::jsonb, '{"area":"life","priority":2}'::jsonb, true, false, 1788624000),
('每周一站会', 'weekly', '{"weekday":1}'::jsonb, '{"area":"work","priority":1}'::jsonb, true, false, 1788624000),
('每月6号账单', 'monthly', '{"day":6}'::jsonb, '{"area":"work","priority":1}'::jsonb, true, false, 1788624000),
('每月15号回顾', 'monthly', '{"day":15}'::jsonb, '{"area":"life","priority":3}'::jsonb, true, false, 1788624000),
('每季末体检', 'quarterly', '{"month_of_quarter":3,"day":6}'::jsonb, '{"area":"life","priority":2}'::jsonb, true, false, 1788624000),
('每年生日', 'yearly', '{"month":9,"day":6}'::jsonb, '{"area":"life","priority":2}'::jsonb, true, false, 1788624000),
('明天才开始的每日', 'daily', '{}'::jsonb, '{"area":"study","priority":3}'::jsonb, true, false, 1788710400),
('过期游标的周日', 'weekly', '{"weekday":7}'::jsonb, '{"area":"life","priority":2}'::jsonb, true, false, 1788537600);
