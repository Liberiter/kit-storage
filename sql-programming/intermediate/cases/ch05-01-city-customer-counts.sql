-- 5장 5.1 «문제 상황»: 도시별 고객 수 — 차례는 있는데 등수 칸이 없다
SELECT city AS 도시, count(*) AS 고객수
FROM customers
GROUP BY city
ORDER BY 고객수 DESC, 도시;
