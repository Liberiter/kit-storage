-- 5장 5.1 «흔한 실수»: 창의 ORDER BY 는 결과의 차례를 정하지 않는다
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT
    rank() OVER (ORDER BY 고객수 DESC) AS 순위,
    도시,
    고객수
FROM city_customers
ORDER BY 도시;
