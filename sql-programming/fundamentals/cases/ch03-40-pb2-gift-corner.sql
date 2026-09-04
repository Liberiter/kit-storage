-- 3장 problem 2 해설: 선물 코너 (어린이 또는 요리, 1만~2만 원, 재고 1권 이상)
SELECT title AS 제목, category AS 분야, price AS "정가(원)"
FROM books
WHERE category IN ('어린이', '요리')
    AND price BETWEEN 10000 AND 20000
    AND stock >= 1 LIMIT 5;
