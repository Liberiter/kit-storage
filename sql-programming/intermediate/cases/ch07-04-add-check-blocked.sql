-- runner: reset
-- 7장 7.1 «따라 하기» 2단계: 이미 든 위반 값이 CHECK 를 막는다 (오류 기대)
ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_price_positive CHECK (supplier_price > 0);
