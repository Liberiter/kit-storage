-- 4장 «도전하기» problem 3 해설: 자기 분야 품절 평균보다 비싼 품절 도서
WITH soldout AS (
    SELECT
        book_id,
        category AS 분야,
        title AS 제목,
        price AS 가격,
        round(avg(price) OVER (PARTITION BY category)) AS 분야평균가
    FROM books
    WHERE stock = 0
)
SELECT 분야, 제목, 가격, 분야평균가
FROM soldout
WHERE 가격 > 분야평균가
ORDER BY 분야, 가격 DESC, book_id;
