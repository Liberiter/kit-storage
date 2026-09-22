-- 6.1 practice 1 — 원장에서 총매출을 내려면 세 칸을 모두 훑어야 한다
SELECT sum(수량 * 단가) AS 총매출
FROM (
    SELECT
        CAST("수량1" AS integer) AS 수량,
        CAST(replace(replace("단가1", ',', ''), '원', '') AS integer) AS 단가
    FROM legacy.sales_ledger
    WHERE "도서1" IS NOT NULL
    UNION ALL
    SELECT
        CAST("수량2" AS integer),
        CAST(replace(replace("단가2", ',', ''), '원', '') AS integer)
    FROM legacy.sales_ledger
    WHERE "도서2" IS NOT NULL
    UNION ALL
    SELECT
        CAST("수량3" AS integer),
        CAST(replace(replace("단가3", ',', ''), '원', '') AS integer)
    FROM legacy.sales_ledger
    WHERE "도서3" IS NOT NULL
) AS pulled;
