-- 3장 3.2 왜 그럴까요: BETWEEN이 양 끝값을 포함한다는 증거 (25000과 30000이 모두 나온다)
SELECT DISTINCT price FROM books WHERE price BETWEEN 25000 AND 30000;
