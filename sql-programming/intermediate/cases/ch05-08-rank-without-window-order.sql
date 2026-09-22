-- 5장 5.1 «흔한 실수»: 창에 ORDER BY 를 적지 않으면 모두 1 등이 된다
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT rank() OVER () AS 순위, 도시, 고객수
FROM city_customers
ORDER BY 고객수 DESC, 도시;
