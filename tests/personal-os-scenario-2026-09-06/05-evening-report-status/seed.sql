insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, completed_at, is_deleted) values
('补做完成', 'study', 'done', 2, 1788537600, null, null, 1788652800, false),
('当天完成', 'work', 'done', 1, 1788624000, null, null, 1788652800+60, false),
('今天还没做', 'work', 'todo', 1, 1788624000, null, null, null, false),
('今天进行中', 'study', 'doing', 2, 1788624000, null, null, null, false),
('今天跳过', 'life', 'skipped', 3, 1788624000, null, null, null, false),
('逾期待做', 'work', 'todo', 1, 1788364800, null, null, null, false),
('逾期跳过', 'life', 'skipped', 3, 1788364800, null, null, null, false);
