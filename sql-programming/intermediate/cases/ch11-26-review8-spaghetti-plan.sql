-- 11장 «복습 exercise» 3 지문 (8장): 동료의 질의를 실행하기 전에 계획부터 — 조인 노드의 rows 어림이 page_views 의 줄 수를 넘는다
EXPLAIN
SELECT
    books.book_id AS 도서번호,
    count(page_views.view_id) AS 조회수,
    sum(order_items.quantity) AS 판매권수
FROM books
LEFT JOIN page_views ON books.book_id = page_views.book_id
LEFT JOIN order_items ON books.book_id = order_items.book_id
GROUP BY books.book_id;
