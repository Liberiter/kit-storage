-- runner: reset
-- 7장 7.1 «practice» 1: 걸리는 줄을 먼저 세고 제약을 걸어 본다 (오류 기대)
SELECT count(*) AS 재고가150을넘는줄
FROM book_supply
WHERE supplier_stock > 150;

ALTER TABLE book_supply
ADD CONSTRAINT book_supply_stock_limit CHECK (supplier_stock <= 150);
