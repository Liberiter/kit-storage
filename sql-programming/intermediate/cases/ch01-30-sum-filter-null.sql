-- 1장 1.3 «흔한 실수»: 맞는 행이 없으면 sum 은 0 이 아니라 널을 낸다
SELECT
    category AS 분야,
    sum(price) FILTER (WHERE price >= 45000) AS 고가합계,
    COALESCE(sum(price) FILTER (WHERE price >= 45000), 0) AS 고가합계보정,
    count(*) FILTER (WHERE price >= 45000) AS 고가권수
FROM books
GROUP BY category
ORDER BY 분야;
