-- 5.1 왜 그럴까요 — `<> NULL`도 0행 (= NULL과 같은 이유)
SELECT order_id, status, shipped_date FROM orders WHERE shipped_date <> NULL;
