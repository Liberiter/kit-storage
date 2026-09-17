-- 1장 «복습 exercise» 1 (앞 코스 9장 — 집계·GROUP BY·HAVING)
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price), 1) AS 평균가격,
    count(*) FILTER (WHERE price >= 30000) AS "3만원 이상"
FROM books
GROUP BY category
HAVING count(*) >= 40
ORDER BY 평균가격 DESC, 분야;
