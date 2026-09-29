-- runner: reset
-- 10장 10.3 «따라 하기» 3단계: 다른 표를 봐야 하는 규칙을 BEFORE 트리거로 검사한다 (오류 기대)
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

INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (2, 6600, 20, '2026-09-08 06:30:00+00');

SELECT book_id, supplier_price FROM book_supply WHERE book_id = 2;

INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
VALUES (3, 23000, 20, '2026-09-08 06:30:00+00');
