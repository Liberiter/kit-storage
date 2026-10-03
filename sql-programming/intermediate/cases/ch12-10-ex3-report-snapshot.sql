-- 12장 «연습하기» exercise 3 해설: 분류별 재고 합계와 전체 재고를 한 REPEATABLE READ 트랜잭션에서 뽑는다
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT category AS 분류, sum(stock) AS 재고합계
FROM books
GROUP BY category
ORDER BY category;
SELECT sum(stock) AS 전체재고 FROM books;
COMMIT;
