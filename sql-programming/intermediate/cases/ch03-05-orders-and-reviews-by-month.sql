-- 3장 3.1 «따라 하기» 4단계: CTE 둘을 테이블처럼 조인한다
WITH monthly_order AS (
    SELECT
        to_char(order_date, 'YYYY-MM') AS 주문월,
        count(*) AS 주문수
    FROM orders
    WHERE order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND status <> '취소'
    GROUP BY to_char(order_date, 'YYYY-MM')
),
monthly_review AS (
    SELECT
        to_char(review_date, 'YYYY-MM') AS 리뷰월,
        count(*) AS 리뷰수
    FROM reviews
    WHERE review_date BETWEEN '2026-01-01' AND '2026-06-30'
    GROUP BY to_char(review_date, 'YYYY-MM')
)
SELECT
    monthly_order.주문월,
    monthly_order.주문수,
    monthly_review.리뷰수
FROM monthly_order
INNER JOIN monthly_review ON monthly_order.주문월 = monthly_review.리뷰월
ORDER BY monthly_order.주문월;
