-- 1장 «연습하기» exercise 3: 분야 × 가격대 교차 요약
SELECT
    category AS 분야,
    count(*) AS 권수,
    count(*) FILTER (WHERE price < 10000) AS "1만원 미만",
    count(*) FILTER (WHERE price >= 10000 AND price < 20000) AS "1만원대",
    count(*) FILTER (WHERE price >= 20000) AS "2만원 이상"
FROM books
GROUP BY category
ORDER BY 권수 DESC, 분야;
