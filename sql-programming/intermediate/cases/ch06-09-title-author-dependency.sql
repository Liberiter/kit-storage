-- 6.1 따라 하기 5단계 — 도서 하나에 저자가 둘인 자리가 있는지 확인한다
SELECT 도서, count(DISTINCT 저자) AS 저자수
FROM (
    SELECT "도서1" AS 도서, "저자1" AS 저자
    FROM legacy.sales_ledger
    WHERE "도서1" IS NOT NULL
    UNION ALL
    SELECT "도서2", "저자2"
    FROM legacy.sales_ledger
    WHERE "도서2" IS NOT NULL
    UNION ALL
    SELECT "도서3", "저자3"
    FROM legacy.sales_ledger
    WHERE "도서3" IS NOT NULL
) AS pulled
GROUP BY 도서
HAVING count(DISTINCT 저자) > 1
ORDER BY 도서;
