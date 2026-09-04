-- runner: reset
-- 복습 exercise 6(9장) 해설 — 리뷰가 5건 이상인 책의 재고를 30으로 채운다
UPDATE books
SET stock = 30
WHERE book_id IN (
    SELECT book_id FROM reviews GROUP BY book_id HAVING count(*) >= 5
);

SELECT count(*) AS 권수, min(stock) AS 최저재고, max(stock) AS 최고재고
FROM books
WHERE book_id IN (
    SELECT book_id FROM reviews GROUP BY book_id HAVING count(*) >= 5
);
