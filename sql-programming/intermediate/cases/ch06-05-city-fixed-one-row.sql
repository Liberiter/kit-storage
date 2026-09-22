-- runner: reset
-- 6.1 따라 하기 3단계 — 줄 하나만 고치면 한 사람에게 두 도시가 생긴다
UPDATE legacy.sales_ledger
SET "고객도시" = '부산'
WHERE "주문번호" = 'ORD-00052';

SELECT "고객도시", count(*) AS 줄수
FROM legacy.sales_ledger
WHERE "고객이메일" = 'jia.jung@bookmail.kr'
GROUP BY "고객도시"
ORDER BY "고객도시";
