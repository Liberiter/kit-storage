-- runner: reset
-- 7장 7.3 «따라 하기» 1단계: INSERT 가 매긴 번호를 RETURNING 으로 받는다
INSERT INTO supplier_feed (
    feed_date, book_id, supplier_price, supplier_stock, received_at
)
VALUES ('2026-09-08', 1, 9800, 40, '2026-09-08 06:30:00+00')
RETURNING feed_id, feed_date, book_id, supplier_price;
