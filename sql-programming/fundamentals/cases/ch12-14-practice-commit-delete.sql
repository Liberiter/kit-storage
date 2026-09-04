-- runner: reset
-- 12.2 practice 2 풀이 — 확인하고 확정한다
BEGIN;
DELETE FROM reviews WHERE rating = 1;

SELECT count(*) AS 남은리뷰, min(rating) AS 최저별점 FROM reviews;

COMMIT;

SELECT count(*) AS 남은리뷰, min(rating) AS 최저별점 FROM reviews;
