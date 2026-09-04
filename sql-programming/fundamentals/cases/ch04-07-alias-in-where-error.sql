-- 4장 4.1 왜 그럴까요: 별칭은 WHERE 절에서 쓸 수 없다 (오류 기대)
SELECT title AS 제목, price AS 정가 FROM books WHERE 정가 <= 8500;
