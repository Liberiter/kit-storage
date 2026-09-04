-- 9.1 따라 하기 4단계: sum으로 주문 5번의 금액 합계를 낸다 (6장 계산 복습)
SELECT sum(unit_price * quantity) AS 금액합계
FROM order_items
WHERE order_id = 5;
