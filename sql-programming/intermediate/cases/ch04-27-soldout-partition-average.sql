-- 4장 4.3 «따라 하기» 1단계: PARTITION BY 로 창을 분야마다 나눈다
SELECT
    category AS 분야,
    title AS 제목,
    price AS 가격,
    round(avg(price) OVER (PARTITION BY category)) AS "분야 평균가"
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, price DESC, book_id;
