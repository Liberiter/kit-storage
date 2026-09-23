-- runner: reset
-- 7장 7.3 «왜 그럴까요»: RETURNING 에는 집계 함수를 쓸 수 없다 (오류 기대)
DELETE FROM supplier_feed WHERE supplier_price <= 0 RETURNING count(*);
