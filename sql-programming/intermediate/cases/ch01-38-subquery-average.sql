-- 1장 «복습 exercise» 2 (앞 코스 10장 — 서브쿼리)
SELECT
    category AS 분야,
    count(*) AS 권수,
    count(*) FILTER (WHERE price > (SELECT avg(price) FROM books))
        AS 평균초과권수
FROM books
GROUP BY category
ORDER BY 평균초과권수 DESC, 분야;
