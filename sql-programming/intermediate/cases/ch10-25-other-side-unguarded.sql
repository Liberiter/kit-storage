-- runner: reset
-- 10장 10.3 «왜 그럴까요»: 판매가를 내리는 쪽은 book_supply 의 트리거가 보지 못한다
CREATE FUNCTION check_supplier_price()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.supplier_price >= (
        SELECT price FROM books WHERE books.book_id = NEW.book_id
    ) THEN
        RAISE EXCEPTION '공급가 %원은 %번 책의 판매가보다 낮아야 합니다',
            NEW.supplier_price, NEW.book_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER book_supply_price_check
BEFORE INSERT OR UPDATE ON book_supply
FOR EACH ROW
EXECUTE FUNCTION check_supplier_price();

UPDATE books SET price = 15000 WHERE book_id = 1;

SELECT books.book_id, books.price, book_supply.supplier_price
FROM books
INNER JOIN book_supply ON books.book_id = book_supply.book_id
WHERE books.book_id = 1;
