-- 11장 11.2 «문제 상황»: Seq Scan 이 조건을 대 보는 줄 수와 남기는 줄 수
SELECT
    count(*) AS 전체조회수,
    count(*) FILTER (WHERE book_id = 12) AS 책12조회수
FROM page_views;
