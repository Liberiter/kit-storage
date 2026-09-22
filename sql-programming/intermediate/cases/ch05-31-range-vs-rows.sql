-- 5장 5.3 «왜 그럴까요»: 기본 프레임(RANGE)은 동등 행을 한 덩어리로 본다
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT
    도시,
    고객수,
    sum(고객수) OVER (ORDER BY 고객수 DESC) AS "누적(기본 프레임)",
    sum(고객수) OVER (
        ORDER BY 고객수 DESC, 도시
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS "누적(ROWS)"
FROM city_customers
ORDER BY 고객수 DESC, 도시;
