-- smoke: 오류 기대 케이스 — CHECK 제약이 음수 공급가를 막는지 (7장 전제, exit≠0)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (9, -1500, 12, '2026-09-01 06:31:00+00');
