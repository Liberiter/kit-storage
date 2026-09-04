-- 7.1 왜 그럴까요: 기본키 열에는 값이 없는 행이 하나도 없다 (0행, 5장 IS NULL)
SELECT customer_id, name FROM customers WHERE customer_id IS NULL;
