-- 9.1 따라 하기 6단계: count(DISTINCT 열)은 널을 뺀 뒤 서로 다른 값을 센다
SELECT
    count(*) AS 리뷰수,
    count(comment) AS 내용있는리뷰수,
    count(DISTINCT comment) AS 내용가짓수
FROM reviews;
