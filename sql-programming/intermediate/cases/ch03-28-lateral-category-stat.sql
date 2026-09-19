-- 3장 3.3 «따라 하기» 3단계: 집계를 담은 LATERAL 은 언제나 한 줄을 낸다
SELECT
    categories.name AS 분류,
    stat.권수,
    stat.평균가
FROM categories
CROSS JOIN LATERAL (
    SELECT count(*) AS 권수, round(avg(books.price)) AS 평균가
    FROM books
    WHERE books.category = categories.name
) AS stat
ORDER BY categories.category_id;
