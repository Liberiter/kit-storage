-- 4장 주장 케이스 — 본문이 인용하지만 출력 블록에서 셀 수 없는 수치를 고정한다.
-- 뒷받침하는 자리는 cases/README.md 의 4장 절에 적었다.
SELECT '책숲의 책 권수' AS claim, count(*) AS value FROM books
UNION ALL
SELECT '책숲의 고객 수', count(*) FROM customers
UNION ALL
SELECT '과학 분야 책 권수', count(*) FROM books WHERE category = '과학'
UNION ALL
SELECT '재고가 0 인 책 권수', count(*) FROM books WHERE stock = 0
UNION ALL
SELECT '재고가 0 이면서 에세이 분야인 책 권수', count(*)
FROM books WHERE stock = 0 AND category = '에세이'
UNION ALL
SELECT '재고가 0 이면서 요리 분야인 책 권수', count(*)
FROM books WHERE stock = 0 AND category = '요리'
UNION ALL
SELECT '재고가 0 이면서 과학 분야인 책 권수', count(*)
FROM books WHERE stock = 0 AND category = '과학'
UNION ALL
SELECT '에세이 분야 가격을 오름차순으로 놓았을 때 22 번째 값', price
FROM (
    SELECT price FROM books WHERE category = '에세이'
    ORDER BY price OFFSET 21 LIMIT 1
) AS t1
UNION ALL
SELECT '에세이 분야 가격을 오름차순으로 놓았을 때 23 번째 값', price
FROM (
    SELECT price FROM books WHERE category = '에세이'
    ORDER BY price OFFSET 22 LIMIT 1
) AS t2
ORDER BY claim;
