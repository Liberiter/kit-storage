-- 6.1 따라 하기 4단계 — 글자로 적힌 단가는 그대로 더할 수 없다 (오류 기대)
SELECT sum(CAST("단가1" AS integer)) AS 단가합
FROM legacy.sales_ledger
WHERE "도서1" IS NOT NULL;
