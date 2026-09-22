-- 6.2 문제 상황 — 원장에서 고객에 관한 사실만 뽑아 본다
SELECT DISTINCT "고객이메일", "고객명", "고객도시"
FROM legacy.sales_ledger
ORDER BY "고객이메일"
LIMIT 5;
