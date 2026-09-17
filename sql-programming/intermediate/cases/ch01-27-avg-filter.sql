-- 1장 1.3 «따라 하기» 4단계: 세는 것 말고 다른 집계에도 FILTER 를 붙인다
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price), 1) AS 평균가격,
    round(avg(price) FILTER (WHERE stock > 0), 1) AS "재고 있는 책 평균가격"
FROM books
GROUP BY category
ORDER BY 분야;
