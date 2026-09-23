-- 7장 7.1 «따라 하기» 1단계: 공급가가 음수인 그 줄을 찾는다
SELECT feed_id, feed_date, book_id, supplier_price, supplier_stock
FROM supplier_feed
WHERE supplier_price <= 0;
