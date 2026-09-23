-- runner: reset
-- 7장 «도전하기» problem 1 해설: 매주 그대로 돌려도 안전한 적재 문장을 두 번 실행한다
WITH clean AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (
            PARTITION BY book_id
            ORDER BY feed_date DESC, feed_id DESC
        ) AS 최신순
    FROM supplier_feed
    WHERE supplier_price > 0
        AND EXISTS (
            SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
        )
),
upserted AS (
    INSERT INTO book_supply (
        book_id, supplier_price, supplier_stock, updated_at
    )
    SELECT book_id, supplier_price, supplier_stock, received_at
    FROM clean
    WHERE 최신순 = 1
    ON CONFLICT (book_id) DO UPDATE
    SET supplier_price = EXCLUDED.supplier_price,
        supplier_stock = EXCLUDED.supplier_stock,
        updated_at = EXCLUDED.updated_at
    WHERE book_supply.updated_at < EXCLUDED.updated_at
    RETURNING OLD.book_id AS 예전
)
SELECT
    count(*) AS 처리한책,
    count(*) FILTER (WHERE 예전 IS NULL) AS 새로넣은책,
    count(*) FILTER (WHERE 예전 IS NOT NULL) AS 고친책
FROM upserted;

WITH clean AS (
    SELECT
        book_id,
        supplier_price,
        supplier_stock,
        received_at,
        row_number() OVER (
            PARTITION BY book_id
            ORDER BY feed_date DESC, feed_id DESC
        ) AS 최신순
    FROM supplier_feed
    WHERE supplier_price > 0
        AND EXISTS (
            SELECT 1 FROM books WHERE books.book_id = supplier_feed.book_id
        )
),
upserted AS (
    INSERT INTO book_supply (
        book_id, supplier_price, supplier_stock, updated_at
    )
    SELECT book_id, supplier_price, supplier_stock, received_at
    FROM clean
    WHERE 최신순 = 1
    ON CONFLICT (book_id) DO UPDATE
    SET supplier_price = EXCLUDED.supplier_price,
        supplier_stock = EXCLUDED.supplier_stock,
        updated_at = EXCLUDED.updated_at
    WHERE book_supply.updated_at < EXCLUDED.updated_at
    RETURNING OLD.book_id AS 예전
)
SELECT
    count(*) AS 처리한책,
    count(*) FILTER (WHERE 예전 IS NULL) AS 새로넣은책,
    count(*) FILTER (WHERE 예전 IS NOT NULL) AS 고친책
FROM upserted;

SELECT count(*) AS 공급현황줄수 FROM book_supply;
