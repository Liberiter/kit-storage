-- 7장 «복습 exercise» 1 해설 (3장 — CTE): 두 날짜에 모두 온 책의 공급가 변화
WITH first_feed AS (
    SELECT DISTINCT book_id, supplier_price
    FROM supplier_feed
    WHERE feed_date = '2026-08-25'
),
second_feed AS (
    SELECT DISTINCT book_id, supplier_price
    FROM supplier_feed
    WHERE feed_date = '2026-09-01'
        AND supplier_price > 0
)
SELECT
    count(*) AS 두날짜모두온책,
    count(*) FILTER (
        WHERE second_feed.supplier_price > first_feed.supplier_price
    ) AS 오른책,
    count(*) FILTER (
        WHERE second_feed.supplier_price < first_feed.supplier_price
    ) AS 내린책,
    count(*) FILTER (
        WHERE second_feed.supplier_price = first_feed.supplier_price
    ) AS 그대로인책
FROM first_feed
INNER JOIN second_feed ON second_feed.book_id = first_feed.book_id;
