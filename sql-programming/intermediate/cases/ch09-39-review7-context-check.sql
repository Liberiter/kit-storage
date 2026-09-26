-- runner: reset
-- 9장 «복습 exercise» 3 해설 (7장): context 에 기기·체류 시간 키가 반드시 있도록 제약을 걸고, 빠진 행을 막는다
ALTER TABLE page_views
ADD CONSTRAINT page_views_context_required_keys
CHECK (context ? 'device' AND context ? 'dwell_ms');

INSERT INTO page_views (viewed_at, book_id, client_tz, context)
VALUES ('2026-09-01 10:00:00+09', 1, 'Asia/Seoul', '{"device": "mobile"}');
