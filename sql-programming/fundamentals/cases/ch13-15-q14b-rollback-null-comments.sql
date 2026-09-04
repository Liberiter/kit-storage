-- runner: reset
-- 13장 exit assessment 문항 14 (나) 해설: 너무 많이 지운 것을 되돌린다
BEGIN;
SELECT count(*) AS "지우기 전 리뷰 수" FROM reviews;
DELETE FROM reviews WHERE comment IS NULL;
SELECT count(*) AS "지운 뒤 리뷰 수" FROM reviews;
ROLLBACK;
SELECT count(*) AS "되돌린 뒤 리뷰 수" FROM reviews;
