-- 5장 5.1 «따라 하기» 3단계: 세 순위 함수를 한 표에 놓고 견준다
WITH city_customers AS (
    SELECT city AS 도시, count(*) AS 고객수
    FROM customers
    GROUP BY city
)
SELECT
    도시,
    고객수,
    row_number() OVER (ORDER BY 고객수 DESC, 도시) AS 번호,
    rank() OVER (ORDER BY 고객수 DESC) AS 순위,
    dense_rank() OVER (ORDER BY 고객수 DESC) AS "촘촘한 순위"
FROM city_customers
ORDER BY 고객수 DESC, 도시;
