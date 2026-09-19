-- 4장 4.3 «practice» 2: 자기 분야 품절 도서 가운데 가장 비싼 책과의 차이
SELECT
    category AS 분야,
    title AS 제목,
    price AS 가격,
    max(price) OVER (PARTITION BY category) AS "분야 최고가",
    max(price) OVER (PARTITION BY category) - price AS 차이
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, price DESC, book_id;
