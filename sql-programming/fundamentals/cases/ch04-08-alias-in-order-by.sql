-- 4장 4.1 왜 그럴까요: 같은 별칭이 ORDER BY 절에서는 그대로 쓰인다
SELECT title AS 제목, price AS 정가
FROM books
WHERE price <= 8500
ORDER BY 정가;
