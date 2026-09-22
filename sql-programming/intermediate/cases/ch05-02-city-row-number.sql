-- 5장 5.1 «따라 하기» 1단계: row_number 로 등수 칸을 붙인다
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT
    row_number() OVER (ORDER BY 고객수 DESC, 도시) AS 순위,
    도시,
    고객수
FROM city_customers
ORDER BY 순위;
