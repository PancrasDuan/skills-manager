insert into tasks (title, area, status, priority, planned_at, due_at, schedule_id, completed_at, is_deleted) values
('今天待做', 'study', 'todo', 2, 1788624000, null, null, null, false),
('今天进行中', 'work', 'doing', 1, 1788624000, null, null, null, false),
('今天已完成', 'work', 'done', 1, 1788624000, null, null, 1788652800, false),
('今天已跳过', 'life', 'skipped', 3, 1788624000, null, null, null, false),
('今天已删除', 'life', 'todo', 3, 1788624000, null, null, null, true),
('逾期待做', 'work', 'todo', 1, 1788364800, null, null, null, false),
('逾期进行中', 'study', 'doing', 2, 1788537600, null, null, null, false),
('逾期已完成', 'work', 'done', 2, 1788364800, null, null, 1788364800+3600, false),
('逾期已跳过', 'life', 'skipped', 3, 1788364800, null, null, null, false);
