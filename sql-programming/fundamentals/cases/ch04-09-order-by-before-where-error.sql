-- 4장 4.1 왜 그럴까요: ORDER BY를 WHERE 앞에 두면 문법 오류 (오류 기대)
SELECT title, price FROM books ORDER BY price WHERE price <= 8500;
