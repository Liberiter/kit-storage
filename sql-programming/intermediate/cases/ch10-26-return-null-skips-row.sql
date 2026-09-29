-- runner: reset
-- 10장 10.3 «흔한 실수»: BEFORE 트리거가 RETURN NULL 로 끝나면 오류 없이 행이 사라진다
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
    RETURN NULL;
END;
$$;

CREATE TRIGGER book_supply_price_check
BEFORE INSERT OR UPDATE ON book_supply
FOR EACH ROW
EXECUTE FUNCTION check_supplier_price();

INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (2, 6600, 20, '2026-09-08 06:30:00+00')
RETURNING book_id;

SELECT count(*) AS 공급현황줄수 FROM book_supply;
