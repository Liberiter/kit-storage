-- 4장 4.1 «문제 상황»: 평균가가 거의 같은 두 분야 (에세이·요리)
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price)) AS 평균가,
    min(price) AS 최저가,
    max(price) AS 최고가
FROM books
WHERE category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;
