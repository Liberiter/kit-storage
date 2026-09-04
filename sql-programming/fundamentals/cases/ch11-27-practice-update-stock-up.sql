-- runner: reset
-- 11.2 practice 2 풀이 — 재고가 0인 소설을 10권씩 채운다
UPDATE books SET stock = stock + 10 WHERE category = '소설' AND stock = 0;

SELECT count(*) AS "재고가 0인 소설"
FROM books
WHERE category = '소설' AND stock = 0;
