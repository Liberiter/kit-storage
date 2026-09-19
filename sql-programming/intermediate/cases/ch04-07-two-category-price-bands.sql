-- 4장 4.1 «왜 그럴까요»: 같은 평균 아래 분포가 어떻게 다른지 센다
SELECT
    category AS 분야,
    count(*) FILTER (WHERE price < 15000) AS "1만5천원 미만",
    count(*) FILTER (WHERE price BETWEEN 15000 AND 34999) AS 중간,
    count(*) FILTER (WHERE price >= 35000) AS "3만5천원 이상"
FROM books
WHERE category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;
