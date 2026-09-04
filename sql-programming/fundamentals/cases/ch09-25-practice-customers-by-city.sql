-- 9.2 practice 1 풀이: 도시별 고객 수 상위 셋
SELECT city AS 도시, count(*) AS 고객수
FROM customers
GROUP BY city
ORDER BY 고객수 DESC, 도시
LIMIT 3;
