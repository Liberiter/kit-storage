-- runner: reset
-- 12.2 practice 1 풀이 — 너무 많이 지운 것을 확정 전에 되돌린다
BEGIN;
DELETE FROM reviews WHERE rating <= 2;

SELECT count(*) AS 남은리뷰 FROM reviews;

ROLLBACK;

SELECT count(*) AS 남은리뷰 FROM reviews;
