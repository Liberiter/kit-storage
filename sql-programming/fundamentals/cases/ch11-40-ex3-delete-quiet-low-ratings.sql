-- runner: reset
-- exercise 3 해설 — 별점이 낮고 한 줄평도 없는 리뷰를 지운다
DELETE FROM reviews WHERE rating <= 2 AND comment IS NULL;

SELECT count(*) AS 남은리뷰 FROM reviews;
