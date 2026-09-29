-- runner: reset
-- 10장 10.3 «문제 상황»: 가격을 바꾸면 RETURNING 이 그 순간에만 예전 값을 보여 준다
UPDATE books
SET price = 12000
WHERE book_id = 2
RETURNING book_id, OLD.price AS 예전가격, NEW.price AS 새가격;

SELECT book_id, price FROM books WHERE book_id = 2;
