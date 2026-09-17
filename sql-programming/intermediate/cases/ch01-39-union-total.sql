-- 1장 «복습 exercise» 3 (앞 코스 10장 — 집합 연산)
SELECT
    category AS 분야,
    count(*) AS 권수,
    count(*) FILTER (WHERE price >= 20000) AS "2만원 이상"
FROM books
GROUP BY category
UNION ALL
SELECT
    '전체',
    count(*),
    count(*) FILTER (WHERE price >= 20000)
FROM books
ORDER BY 권수 DESC, 분야;
