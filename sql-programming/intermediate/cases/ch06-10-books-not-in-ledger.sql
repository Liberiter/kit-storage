-- 6.1 따라 하기 6단계 — 아직 팔리지 않은 책은 원장에 적힐 자리가 없다
SELECT
    (SELECT count(*) FROM books) AS 책숲도서,
    count(DISTINCT 도서) AS 원장도서
FROM (
    SELECT "도서1" AS 도서
    FROM legacy.sales_ledger
    WHERE "도서1" IS NOT NULL
    UNION ALL
    SELECT "도서2"
    FROM legacy.sales_ledger
    WHERE "도서2" IS NOT NULL
    UNION ALL
    SELECT "도서3"
    FROM legacy.sales_ledger
    WHERE "도서3" IS NOT NULL
) AS pulled;
