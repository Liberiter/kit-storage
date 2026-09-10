-- 입장 점검 문항 4 의 확인 질의 — entry_check.sh 가 여러분의 트랜잭션을 실행한 뒤 이것을 돌려
-- 기대 결과(entry/expected/q4.expected)와 대조한다. 여러분이 고칠 파일이 아니다.
SELECT o.customer_id, o.order_date, o.status, o.shipped_date,
       oi.book_id, oi.quantity, oi.unit_price,
       b.stock AS stock_after,
       (SELECT count(*) FROM orders WHERE order_date = '2026-09-01') AS orders_on_day
  FROM orders o
  JOIN order_items oi USING (order_id)
  JOIN books b USING (book_id)
 WHERE o.order_date = '2026-09-01'
 ORDER BY o.order_id, oi.book_id;
