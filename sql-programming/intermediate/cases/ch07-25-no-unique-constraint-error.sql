-- runner: reset
-- 7장 7.2 «흔한 실수»: 유일 제약이 없는 열을 충돌 대상으로 적을 수 없다 (오류 기대)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (19, 6200, 62, '2026-08-25 06:30:19+00')
ON CONFLICT (supplier_price) DO NOTHING;
