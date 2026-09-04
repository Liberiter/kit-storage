-- runner: reset
-- 11.3 practice 2 풀이 — 별점 1점짜리 리뷰를 모두 지운다
DELETE FROM reviews WHERE rating = 1;

SELECT count(*) AS 남은리뷰, min(rating) AS 최저별점 FROM reviews;
