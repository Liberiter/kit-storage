-- 입장 점검 문항 3 참조 해답 (entry_check.sh --reference 가 쓴다)
SELECT category, count(*) AS book_count, round(avg(price)) AS avg_price
FROM books
GROUP BY category
ORDER BY category;
