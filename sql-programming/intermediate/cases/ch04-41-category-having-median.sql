-- 4장 «복습 exercise» 2 해설 (앞 코스 9장 — 집계·GROUP BY·HAVING)
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price)) AS 평균가,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS 중앙값
FROM books
GROUP BY category
HAVING count(*) >= 40
ORDER BY 권수 DESC, 분야;
