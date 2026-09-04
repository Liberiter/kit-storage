-- 9.1 따라 하기 5단계: count(*)와 count(열)의 차이 (널을 세는가)
SELECT count(*) AS 리뷰수, count(comment) AS 내용있는리뷰수 FROM reviews;
