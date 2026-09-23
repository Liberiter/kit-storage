-- runner: reset
-- 7장 7.1 «따라 하기» 3단계: 위반 줄을 치운 뒤 CHECK 를 걸고 \d 로 확인
DELETE FROM supplier_feed WHERE supplier_price <= 0;

ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_price_positive CHECK (supplier_price > 0);

\d supplier_feed
