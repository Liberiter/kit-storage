-- 1장 1.3 «practice» 1: 분야마다 전체 권수와 품절 권수, 품절 비율
SELECT
    category AS 분야,
    count(*) AS 권수,
    count(*) FILTER (WHERE stock = 0) AS 품절권수,
    round(100.0 * count(*) FILTER (WHERE stock = 0) / count(*), 1)
        AS "품절률(%)"
FROM books
GROUP BY category
ORDER BY "품절률(%)" DESC, 분야;
