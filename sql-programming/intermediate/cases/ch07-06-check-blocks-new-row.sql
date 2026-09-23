-- runner: reset
-- 7장 7.1 «따라 하기» 4단계: 제약이 걸린 표는 새 음수 가격을 막는다 (오류 기대)
DELETE FROM supplier_feed WHERE supplier_price <= 0;

ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_price_positive CHECK (supplier_price > 0);

INSERT INTO supplier_feed (
    feed_date, book_id, supplier_price, supplier_stock, received_at
)
VALUES ('2026-09-08', 1, -9800, 40, '2026-09-08 06:30:00+00');
