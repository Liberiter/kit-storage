-- 6.1 따라 하기 5단계 — 이름은 사람을 가려내지 못한다 (동명이인)
SELECT "고객명", count(DISTINCT "고객이메일") AS 이메일수
FROM legacy.sales_ledger
GROUP BY "고객명"
HAVING count(DISTINCT "고객이메일") > 1
ORDER BY "고객명";
