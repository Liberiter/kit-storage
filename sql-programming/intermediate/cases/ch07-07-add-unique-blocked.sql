-- runner: reset
-- 7장 7.1 «따라 하기» 5단계: 같은 날 같은 책이 두 줄이라 UNIQUE 가 막힌다 (오류 기대)
ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_date_book_unique UNIQUE (feed_date, book_id);
