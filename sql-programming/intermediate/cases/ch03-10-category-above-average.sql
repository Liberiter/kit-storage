-- 3장 3.1 «practice» 1: 분야 평균가가 전체 분야 평균보다 높은 분야
WITH category_price AS (
    SELECT category AS 분야, round(avg(price)) AS 평균가
    FROM books
    GROUP BY category
)
SELECT 분야, 평균가
FROM category_price
WHERE 평균가 >= (SELECT avg(평균가) FROM category_price)
ORDER BY 평균가 DESC, 분야;
