-- 7.2 practice 2 풀이 (1): 주문 1번이 가리키는 고객 번호
SELECT order_id, customer_id, order_date, status FROM orders WHERE order_id = 1;
