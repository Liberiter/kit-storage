-- 6.1 따라 하기 1단계 — 세 칸을 세로로 펴서 다시 센 「많이 팔린 책」
SELECT 도서, sum(수량) AS 판매수량
FROM (
    SELECT "도서1" AS 도서, CAST("수량1" AS integer) AS 수량
    FROM legacy.sales_ledger
    WHERE "도서1" IS NOT NULL
    UNION ALL
    SELECT "도서2", CAST("수량2" AS integer)
    FROM legacy.sales_ledger
    WHERE "도서2" IS NOT NULL
    UNION ALL
    SELECT "도서3", CAST("수량3" AS integer)
    FROM legacy.sales_ledger
    WHERE "도서3" IS NOT NULL
) AS pulled
GROUP BY 도서
ORDER BY 판매수량 DESC, 도서
LIMIT 5;
