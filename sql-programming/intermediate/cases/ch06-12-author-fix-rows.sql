-- 6.1 practice 2 — 저자 이름 하나를 고치려면 몇 줄을 손봐야 하는가
SELECT count(*) AS 고칠줄수
FROM legacy.sales_ledger
WHERE "저자1" = '권수아' OR "저자2" = '권수아' OR "저자3" = '권수아';
