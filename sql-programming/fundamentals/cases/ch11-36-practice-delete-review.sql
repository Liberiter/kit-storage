-- runner: reset
-- 11.3 practice 1 풀이 — 리뷰 한 건을 지우고 확인한다
DELETE FROM reviews WHERE review_id = 3;

SELECT
    (SELECT count(*) FROM reviews WHERE review_id = 3) AS "3번 리뷰",
    (SELECT count(*) FROM reviews) AS "리뷰 전체";
