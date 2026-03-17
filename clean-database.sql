-- Clean Database Script for Task Tracker
-- Execute these queries in order to delete all data safely

-- 1. Delete all activity logs (no dependencies)
DELETE FROM public.activity_logs;

-- 2. Delete all comments (depends on tasks)
DELETE FROM public.comments;

-- 3. Delete all tasks (depends on projects)
DELETE FROM public.tasks;

-- 4. Delete all projects (depends on users, but user is just owner)
DELETE FROM public.projects;

-- 5. (Optional) Delete all users - ONLY if you want fresh users too
-- DELETE FROM public.users;

-- Reset sequences/auto-increment counters (PostgreSQL)
ALTER SEQUENCE activity_logs_id_seq RESTART WITH 1;
ALTER SEQUENCE comments_id_seq RESTART WITH 1;
ALTER SEQUENCE tasks_id_seq RESTART WITH 1;
ALTER SEQUENCE projects_id_seq RESTART WITH 1;
-- ALTER SEQUENCE users_id_seq RESTART WITH 1;

-- Verify data is deleted
SELECT 'activity_logs' as table_name, COUNT(*) FROM public.activity_logs
UNION ALL
SELECT 'comments', COUNT(*) FROM public.comments
UNION ALL
SELECT 'tasks', COUNT(*) FROM public.tasks
UNION ALL
SELECT 'projects', COUNT(*) FROM public.projects
UNION ALL
SELECT 'users', COUNT(*) FROM public.users;
