-- 4장 4.3 «따라 하기» 2단계: 자기 분야 평균과의 차이
SELECT
    category AS 분야,
    title AS 제목,
    price AS 가격,
    round(avg(price) OVER (PARTITION BY category)) AS "분야 평균가",
    price - round(avg(price) OVER (PARTITION BY category)) AS 차이
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, price DESC, book_id;
