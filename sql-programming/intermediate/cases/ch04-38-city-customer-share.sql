-- 4장 «연습하기» exercise 3 해설: 도시별 고객 수와 전체 대비 비중
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT 도시, 고객수, round(100.0 * 고객수 / sum(고객수) OVER (), 1) AS "비중(%)"
FROM city_customers
ORDER BY 고객수 DESC, 도시;
