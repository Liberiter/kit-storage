-- exercise 1 해설: 분야별 재고 합계
SELECT category AS 분야, sum(stock) AS 재고합계
FROM books
GROUP BY category
ORDER BY 재고합계 DESC, 분야;
