-- 3장 주장 케이스 — 본문이 인용하지만 출력 블록에서 셀 수 없는 수치를 고정한다.
-- 뒷받침하는 자리는 cases/README.md 의 3장 절에 적었다.
SELECT '책숲의 직원 수' AS claim, count(*) AS value FROM staff
UNION ALL
SELECT '상사가 없는 직원 수', count(*) FROM staff WHERE manager_id IS NULL
UNION ALL
SELECT '조직에서 가장 깊은 단계', max(단계)
FROM (
    WITH RECURSIVE org AS (
        SELECT staff_id, 1 AS 단계 FROM staff WHERE manager_id IS NULL
        UNION ALL
        SELECT staff.staff_id, org.단계 + 1
        FROM staff
        INNER JOIN org ON staff.manager_id = org.staff_id
    )
    SELECT 단계 FROM org
) AS t1
UNION ALL
SELECT '3번 직원과 그 아래 전원의 수', count(*)
FROM (
    WITH RECURSIVE sub AS (
        SELECT staff_id FROM staff WHERE staff_id = 3
        UNION ALL
        SELECT staff.staff_id
        FROM staff
        INNER JOIN sub ON staff.manager_id = sub.staff_id
    )
    SELECT staff_id FROM sub
) AS t2
UNION ALL
SELECT '23번 직원에서 대표까지 거슬러 오른 단계 수', max(단계)
FROM (
    WITH RECURSIVE chain AS (
        SELECT staff_id, manager_id, 1 AS 단계 FROM staff WHERE staff_id = 23
        UNION ALL
        SELECT staff.staff_id, staff.manager_id, chain.단계 + 1
        FROM staff
        INNER JOIN chain ON staff.staff_id = chain.manager_id
    )
    SELECT 단계 FROM chain
) AS t3
UNION ALL
SELECT '분류 트리의 분류 수', count(*) FROM categories
UNION ALL
SELECT '책이 한 권 이상 달린 분류 수', count(*)
FROM categories
WHERE EXISTS (SELECT 1 FROM books WHERE books.category = categories.name)
UNION ALL
SELECT '책이 한 권도 없는 분류 수', count(*)
FROM categories
WHERE NOT EXISTS (SELECT 1 FROM books WHERE books.category = categories.name)
UNION ALL
SELECT '팔린 적이 없는 책 권수', count(*)
FROM books
WHERE NOT EXISTS (
    SELECT 1 FROM order_items WHERE order_items.book_id = books.book_id
)
UNION ALL
SELECT '2026년 상반기 여섯 달의 판매권수 평균', round(avg(판매권수))
FROM (
    SELECT sum(order_items.quantity) AS 판매권수
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2026-01-01' AND '2026-06-30'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
) AS t4
UNION ALL
SELECT '2026년 상반기 리뷰가 한 건 이상 달린 달 수', count(DISTINCT 리뷰월)
FROM (
    SELECT to_char(review_date, 'YYYY-MM') AS 리뷰월
    FROM reviews
    WHERE review_date BETWEEN '2026-01-01' AND '2026-06-30'
) AS t5
UNION ALL
SELECT '2025년 취소를 뺀 주문이 있는 달 수', count(*)
FROM (
    SELECT to_char(orders.order_date, 'YYYY-MM') AS 주문월
    FROM orders
    INNER JOIN order_items ON orders.order_id = order_items.order_id
    WHERE orders.order_date BETWEEN '2025-01-01' AND '2025-12-31'
        AND orders.status <> '취소'
    GROUP BY to_char(orders.order_date, 'YYYY-MM')
) AS t6
ORDER BY claim;
