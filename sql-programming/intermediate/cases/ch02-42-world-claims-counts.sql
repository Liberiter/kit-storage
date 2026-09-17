-- 2장 주장 케이스 — 본문이 인용하지만 출력 블록에서 셀 수 없는 수치를 고정한다.
-- 뒷받침하는 자리는 cases/README.md 의 2장 절에 적었다.
SELECT '책숲의 책 권수' AS claim, count(*) AS value FROM books
UNION ALL
SELECT '책숲의 고객 수', count(*) FROM customers
UNION ALL
SELECT '책숲의 직원 수', count(*) FROM staff
UNION ALL
SELECT '상사번호가 널인 직원 수', count(*) FROM staff WHERE manager_id IS NULL
UNION ALL
SELECT '부하가 없는 직원 수', count(*)
FROM staff AS s
WHERE NOT EXISTS (SELECT 1 FROM staff AS x WHERE x.manager_id = s.staff_id)
UNION ALL
SELECT '리뷰가 한 건도 없는 책 권수', count(*)
FROM books
WHERE NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id)
UNION ALL
SELECT '리뷰가 하나라도 달린 책 권수', count(*)
FROM books
WHERE EXISTS (SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id)
UNION ALL
SELECT '팔린 적이 없는 책 권수', count(*)
FROM books
WHERE NOT EXISTS (
    SELECT 1 FROM order_items WHERE order_items.book_id = books.book_id
)
UNION ALL
SELECT '주문도 하고 리뷰도 쓴 고객 수', count(*)
FROM customers
WHERE EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
UNION ALL
SELECT '주문은 했지만 리뷰는 쓰지 않은 고객 수', count(*)
FROM customers
WHERE EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
UNION ALL
SELECT '리뷰는 썼지만 주문은 하지 않은 고객 수', count(*)
FROM customers
WHERE EXISTS (
    SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
    )
UNION ALL
SELECT '주문도 리뷰도 없는 고객 수', count(*)
FROM customers
WHERE NOT EXISTS (
    SELECT 1 FROM orders WHERE orders.customer_id = customers.customer_id
)
    AND NOT EXISTS (
        SELECT 1 FROM reviews WHERE reviews.customer_id = customers.customer_id
    )
UNION ALL
SELECT '재고 원장에서 reason 이 입고인 행 수', count(*)
FROM stock_movements WHERE reason = '입고'
UNION ALL
SELECT '재고 원장에서 reason 이 출고인 행 수', count(*)
FROM stock_movements WHERE reason = '출고'
UNION ALL
SELECT '재고 원장에서 reason 이 입고도 출고도 아닌 행 수', count(*)
FROM stock_movements WHERE reason <> '입고' AND reason <> '출고'
UNION ALL
SELECT '주문 날짜까지 함께 견준 EXCEPT 가 남기는 행 수', count(*)
FROM (
    SELECT customer_id, order_date FROM orders
    EXCEPT
    SELECT customer_id, review_date FROM reviews
) AS t
ORDER BY claim;
