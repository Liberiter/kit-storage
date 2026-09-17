-- 1장 1.3 «practice» 2: 최고가와 재고가 넉넉한 책만의 최고가
SELECT
    category AS 분야,
    max(price) AS 최고가,
    max(price) FILTER (WHERE stock >= 10) AS "재고 10권 이상 최고가"
FROM books
GROUP BY category
ORDER BY 분야;
