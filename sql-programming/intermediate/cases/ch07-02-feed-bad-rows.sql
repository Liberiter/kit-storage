-- 7장 7.1 «문제 상황»: 피드에 이미 들어와 있는 위반 값 세기
SELECT
    count(*) AS 피드줄수,
    count(*) FILTER (WHERE supplier_price <= 0) AS 공급가가음수,
    count(*) FILTER (
        WHERE NOT EXISTS (
            SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
        )
    ) AS 없는책번호
FROM supplier_feed;

SELECT feed_date, book_id, count(*) AS 줄수
FROM supplier_feed
GROUP BY feed_date, book_id
HAVING count(*) > 1
ORDER BY feed_date, book_id;
