-- 9.3 practice 2 풀이: 고객이 15명 이상인 도시
SELECT city AS 도시, count(*) AS 고객수
FROM customers
GROUP BY city
HAVING count(*) >= 15
ORDER BY 고객수 DESC, 도시;
