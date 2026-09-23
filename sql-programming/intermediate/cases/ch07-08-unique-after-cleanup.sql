-- runner: reset
-- 7장 7.1 «따라 하기» 6단계: 중복을 치우고 UNIQUE 를 건 뒤 같은 줄을 또 넣어 본다 (오류 기대)
DELETE FROM supplier_feed
WHERE feed_id IN (
    SELECT max(feed_id)
    FROM supplier_feed
    GROUP BY feed_date, book_id
    HAVING count(*) > 1
);

ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_date_book_unique UNIQUE (feed_date, book_id);

INSERT INTO supplier_feed (
    feed_date, book_id, supplier_price, supplier_stock, received_at
)
VALUES ('2026-08-25', 2, 6800, 20, '2026-08-25 06:30:02+00');
