-- smoke: 오류 기대 케이스 — FK 위반이 막히는지 (11장 전제, exit≠0)
INSERT INTO orders (customer_id, order_date, status)
VALUES (999999, '2026-08-24', '배송준비');
