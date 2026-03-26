-- 002_seed_demo_data.sql
-- Demo data seed. Safe to re-run via ON CONFLICT DO NOTHING.

BEGIN;

-- Demo users (NOTE: password_hash values are placeholders; backend auth should replace with real hashes)
-- Use fixed UUIDs for stable references across runs.
INSERT INTO public.users (id, email, password_hash, is_active)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'student1@example.com', 'demo_hash_student1', true),
  ('22222222-2222-2222-2222-222222222222', 'student2@example.com', 'demo_hash_student2', true),
  ('33333333-3333-3333-3333-333333333333', 'teacher1@example.com', 'demo_hash_teacher1', true),
  ('44444444-4444-4444-4444-444444444444', 'admin1@example.com',   'demo_hash_admin1', true)
ON CONFLICT (id) DO NOTHING;

-- Roles
INSERT INTO public.user_roles (user_id, role) VALUES
  ('11111111-1111-1111-1111-111111111111', 'student'),
  ('22222222-2222-2222-2222-222222222222', 'student'),
  ('33333333-3333-3333-3333-333333333333', 'teacher'),
  ('44444444-4444-4444-4444-444444444444', 'admin')
ON CONFLICT DO NOTHING;

-- Profiles
INSERT INTO public.profiles (user_id, display_name, grade_level, major, bio)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'Alex Student', '11', 'Computer Science', 'Demo student profile'),
  ('22222222-2222-2222-2222-222222222222', 'Jamie Student', '12', 'Mathematics', 'Another demo student'),
  ('33333333-3333-3333-3333-333333333333', 'Taylor Teacher', NULL, NULL, 'Demo teacher profile'),
  ('44444444-4444-4444-4444-444444444444', 'Casey Admin', NULL, NULL, 'Demo admin profile')
ON CONFLICT (user_id) DO NOTHING;

-- Classes
INSERT INTO public.classes (id, code, name, description, term, location, meeting_days, start_time, end_time, created_by_user_id)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'MATH-101', 'Calculus I', 'Limits, derivatives, and integrals', 'Spring 2026', 'Room 204', ARRAY['Mon','Wed'], '09:00', '10:15', '33333333-3333-3333-3333-333333333333'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'ENG-201',  'English Literature', 'Classic and modern works',     'Spring 2026', 'Room 110', ARRAY['Tue','Thu'], '11:00', '12:15', '33333333-3333-3333-3333-333333333333')
ON CONFLICT (id) DO NOTHING;

-- Enrollments
INSERT INTO public.class_enrollments (class_id, user_id, enrollment_role)
VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'student'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '22222222-2222-2222-2222-222222222222', 'student'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '33333333-3333-3333-3333-333333333333', 'teacher'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'student'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', 'teacher')
ON CONFLICT DO NOTHING;

-- Assignments
INSERT INTO public.assignments (id, class_id, title, description, due_at, max_points, status, created_by_user_id)
VALUES
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Homework 1', 'Derivative practice set', now() + interval '7 days', 100, 'in_progress', '33333333-3333-3333-3333-333333333333'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Quiz 1', 'Limits & continuity quiz',  now() + interval '10 days', 20,  'not_started', '33333333-3333-3333-3333-333333333333'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Reading Response', 'Write 500 words on assigned reading', now() + interval '5 days', 50, 'submitted', '33333333-3333-3333-3333-333333333333')
ON CONFLICT (id) DO NOTHING;

-- Grades (some graded)
INSERT INTO public.grades (id, assignment_id, student_user_id, points_earned, feedback, graded_by_user_id, graded_at)
VALUES
  ('f1111111-1111-1111-1111-111111111111', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '11111111-1111-1111-1111-111111111111', 45, 'Nice analysis; tighten conclusion.', '33333333-3333-3333-3333-333333333333', now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;

-- Announcements
INSERT INTO public.announcements (id, class_id, title, body, posted_by_user_id, posted_at, is_pinned)
VALUES
  ('a1111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Welcome to Calculus I', 'Syllabus is posted. Office hours Wed 2-4pm.', '33333333-3333-3333-3333-333333333333', now() - interval '3 days', true),
  ('b1111111-1111-1111-1111-111111111111', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'First reading assigned', 'Please read chapters 1-2 before next class.', '33333333-3333-3333-3333-333333333333', now() - interval '2 days', false)
ON CONFLICT (id) DO NOTHING;

-- Notifications (simple demo notifications)
INSERT INTO public.notifications (id, user_id, type, title, body, is_read, metadata, created_at)
VALUES
  ('n1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'announcement', 'New announcement in MATH-101', 'Welcome to Calculus I', false, '{"announcement_id":"a1111111-1111-1111-1111-111111111111","class_id":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"}', now() - interval '3 days'),
  ('n2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'grade',        'Grade posted: Reading Response', 'You scored 45/50', false, '{"assignment_id":"eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"}', now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;

-- Todos
INSERT INTO public.todos (id, user_id, class_id, title, details, due_at, status)
VALUES
  ('t1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Finish Homework 1', 'Complete problems 1-20', now() + interval '6 days', 'open'),
  ('t2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', NULL, 'Update profile bio', 'Add a short bio in your profile settings', NULL, 'open')
ON CONFLICT (id) DO NOTHING;

COMMIT;
