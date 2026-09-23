-- runner: reset
-- 7장 7.3 «따라 하기» 3단계: DELETE 가 지운 줄을 RETURNING 으로 받아 둔다
DELETE FROM supplier_feed
WHERE supplier_price <= 0
RETURNING feed_id, feed_date, book_id, supplier_price;
