-- 5장 5.1 «따라 하기» 2단계: rank 는 동점에 같은 등수를 준다
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
ORDER BY 고객수 DESC, 도시;
