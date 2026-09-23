-- runner: reset
-- 7장 7.2 «따라 하기» 4단계: 같은 문장을 두 번 실행해도 결과가 같다
WITH one_per_book AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (PARTITION BY book_id ORDER BY feed_id) AS 줄번호
    FROM supplier_feed
    WHERE feed_date = '2026-08-25'
)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM one_per_book
WHERE 줄번호 = 1
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;

WITH one_per_book AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (PARTITION BY book_id ORDER BY feed_id) AS 줄번호
    FROM supplier_feed
    WHERE feed_date = '2026-08-25'
)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM one_per_book
WHERE 줄번호 = 1
ON CONFLICT (book_id) DO UPDATE
SET supplier_price = EXCLUDED.supplier_price,
    supplier_stock = EXCLUDED.supplier_stock,
    updated_at = EXCLUDED.updated_at;

SELECT count(*) AS 공급현황줄수 FROM book_supply;

SELECT book_id, supplier_price, supplier_stock, updated_at
FROM book_supply
WHERE book_id = 19;
