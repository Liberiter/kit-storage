-- problem 3 해설 — 한 번도 주문되지 않은 책이 몇 권인지 먼저 센다
SELECT count(*) AS 대상권수
FROM books
WHERE book_id NOT IN (SELECT book_id FROM order_items);
