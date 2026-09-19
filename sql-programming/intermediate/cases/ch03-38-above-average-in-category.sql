-- 3장 «연습하기» exercise 4 해설: 분야 평균가를 CTE 로 내고 LATERAL 이 그 값을 쓴다
WITH category_avg AS (
    SELECT category AS 분야, round(avg(price)) AS 평균가
    FROM books
    GROUP BY category
)
SELECT
    category_avg.분야,
    category_avg.평균가,
    expensive.title AS 제목,
    expensive.price AS 가격
FROM category_avg
CROSS JOIN LATERAL (
    SELECT books.title, books.price
    FROM books
    WHERE books.category = category_avg.분야
        AND books.price > category_avg.평균가
    ORDER BY books.price, books.book_id
    LIMIT 2
) AS expensive
ORDER BY category_avg.분야, expensive.price;
