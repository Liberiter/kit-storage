-- runner: reset
-- 7장 «연습하기» exercise 4 해설: 공급가가 싸진 책만 갱신한다
WITH one_per_book AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (PARTITION BY book_id ORDER BY feed_id) AS 줄번호
    FROM supplier_feed
    WHERE feed_date = '2026-08-25'
),
upserted AS (
    INSERT INTO book_supply (
        book_id, supplier_price, supplier_stock, updated_at
    )
    SELECT book_id, supplier_price, supplier_stock, received_at
    FROM one_per_book
    WHERE 줄번호 = 1
    ON CONFLICT (book_id) DO UPDATE
    SET supplier_price = EXCLUDED.supplier_price,
        supplier_stock = EXCLUDED.supplier_stock,
        updated_at = EXCLUDED.updated_at
    WHERE EXCLUDED.supplier_price < book_supply.supplier_price
    RETURNING OLD.book_id AS 예전
)
SELECT
    count(*) AS 처리한책,
    count(*) FILTER (WHERE 예전 IS NULL) AS 새로넣은책,
    count(*) FILTER (WHERE 예전 IS NOT NULL) AS 고친책
FROM upserted;
