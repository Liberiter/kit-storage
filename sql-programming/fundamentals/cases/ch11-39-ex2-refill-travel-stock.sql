-- runner: reset
-- exercise 2 해설 — 재고가 5권 미만인 여행 책을 20권으로 채운다
UPDATE books SET stock = 20 WHERE category = '여행' AND stock < 5;

SELECT count(*) AS 권수, min(stock) AS 최저재고, max(stock) AS 최고재고
FROM books
WHERE category = '여행';
