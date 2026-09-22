-- 6.1 따라 하기 2단계 — 한 고객의 이름·도시가 몇 줄에 되풀이되는가
SELECT "주문번호", "주문일", "고객명", "고객도시"
FROM legacy.sales_ledger
WHERE "고객이메일" = 'jia.jung@bookmail.kr'
ORDER BY "주문번호";
