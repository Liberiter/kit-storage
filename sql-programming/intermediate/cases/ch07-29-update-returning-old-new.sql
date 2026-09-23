-- runner: reset
-- 7장 7.3 «따라 하기» 2단계: UPDATE 가 바꾼 행의 예전 값과 새 값을 함께 받는다
UPDATE book_supply
SET supplier_stock = supplier_stock + 10
WHERE book_id IN (19, 29, 45)
RETURNING
    book_id,
    OLD.supplier_stock AS 예전재고,
    NEW.supplier_stock AS 바뀐재고;
