-- 11장 «복습 exercise» 3 해설 (8장): 질문마다 따로 센 뒤 잇는다 — 계획에서 집계가 조인 아래로 내려가고 어림은 320줄, 앞 세 권의 수
EXPLAIN
WITH view_counts AS (
    SELECT book_id, count(*) AS view_count
    FROM page_views
    GROUP BY book_id
),
sold_units AS (
    SELECT book_id, sum(quantity) AS units_sold
    FROM order_items
    GROUP BY book_id
)
SELECT
    books.book_id AS 도서번호,
    view_counts.view_count AS 조회수,
    sold_units.units_sold AS 판매권수
FROM books
LEFT JOIN view_counts ON books.book_id = view_counts.book_id
LEFT JOIN sold_units ON books.book_id = sold_units.book_id;

WITH view_counts AS (
    SELECT book_id, count(*) AS view_count
    FROM page_views
    GROUP BY book_id
),
sold_units AS (
    SELECT book_id, sum(quantity) AS units_sold
    FROM order_items
    GROUP BY book_id
)
SELECT
    books.book_id AS 도서번호,
    view_counts.view_count AS 조회수,
    sold_units.units_sold AS 판매권수
FROM books
LEFT JOIN view_counts ON books.book_id = view_counts.book_id
LEFT JOIN sold_units ON books.book_id = sold_units.book_id
WHERE books.book_id <= 3
ORDER BY books.book_id;
