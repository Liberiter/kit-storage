-- 6.1 practice 2 해설: WHERE를 빼면 소요일이 없는 주문이 DESC 정렬에서 맨 앞을
-- 차지한다 (5장 5.1절 «왜 그럴까요»의 규칙이 계산 결과에도 그대로 적용된다)
SELECT order_id, order_date, shipped_date, shipped_date - order_date AS 소요일
FROM orders
ORDER BY 소요일 DESC, order_id
LIMIT 5;
