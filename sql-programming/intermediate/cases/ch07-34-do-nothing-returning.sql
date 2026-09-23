-- runner: reset
-- 7장 7.3 «흔한 실수»: DO NOTHING 이 건너뛴 줄은 RETURNING 에 나오지 않는다
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES
    (19, 6200, 62, '2026-08-25 06:30:19+00'),
    (2, 6300, 63, '2026-09-01 06:30:02+00')
ON CONFLICT (book_id) DO NOTHING
RETURNING book_id, supplier_price;
