-- runner: reset
-- smoke: 변경형 케이스 — 공급 피드를 정리해 book_supply 에 UPSERT 하고 결과를 확인한다 (7장 요구 예시)
WITH latest AS (
    SELECT DISTINCT ON (book_id) book_id, supplier_price, supplier_stock, received_at
    FROM supplier_feed f
    WHERE supplier_price > 0
      AND EXISTS (SELECT 1 FROM books b WHERE b.book_id = f.book_id)
    ORDER BY book_id, feed_date DESC, received_at DESC
)
INSERT INTO book_supply (book_id, supplier_price, supplier_stock, updated_at)
SELECT book_id, supplier_price, supplier_stock, received_at
FROM latest
ON CONFLICT (book_id) DO UPDATE
    SET supplier_price = EXCLUDED.supplier_price,
        supplier_stock = EXCLUDED.supplier_stock,
        updated_at     = EXCLUDED.updated_at
RETURNING book_id, (xmax = 0) AS inserted;

SELECT count(*) AS supply_rows,
       count(*) FILTER (WHERE updated_at >= '2026-08-25') AS touched_by_feed
FROM book_supply;
