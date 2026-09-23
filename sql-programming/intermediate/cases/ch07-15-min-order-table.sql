-- runner: reset
-- 7장 7.1 «practice» 2: 제약을 함께 적은 표를 만들고 위반 값을 넣어 본다 (오류 기대)
CREATE TABLE book_min_orders (
    book_id integer PRIMARY KEY REFERENCES books (book_id),
    min_quantity integer NOT NULL CHECK (min_quantity >= 1)
);

INSERT INTO book_min_orders (book_id, min_quantity)
VALUES
    (1, 10),
    (2, 5);

SELECT book_id, min_quantity FROM book_min_orders ORDER BY book_id;

INSERT INTO book_min_orders (book_id, min_quantity)
VALUES (3, 0);
