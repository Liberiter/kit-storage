-- runner: reset
-- 10장 «연습하기» exercise 4 해설: 재고를 손으로 고치면 원장에 조정 줄이 저절로 남는다
CREATE FUNCTION record_stock_adjustment()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.stock <> OLD.stock THEN
        INSERT INTO stock_movements (
            book_id, moved_at, quantity, reason, staff_id
        )
        VALUES (NEW.book_id, now(), NEW.stock - OLD.stock, '조정', 3);
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER books_stock_ledger
AFTER UPDATE OF stock ON books
FOR EACH ROW
EXECUTE FUNCTION record_stock_adjustment();

UPDATE books SET stock = stock - 2 WHERE book_id = 3;
UPDATE books SET stock = stock WHERE book_id = 4;

SELECT movement_id, book_id, quantity, reason, staff_id
FROM stock_movements
WHERE reason = '조정';

SELECT count(*) AS 어긋난책
FROM books
WHERE stock <> (
    SELECT sum(quantity)
    FROM stock_movements
    WHERE stock_movements.book_id = books.book_id
);
