-- 연습하기 exercise 1 — 주문번호 하나가 줄 하나인지 확인한다
SELECT count(*) AS 주문번호수, max(줄수) AS 최대줄수
FROM (
    SELECT "주문번호", count(*) AS 줄수
    FROM legacy.sales_ledger
    GROUP BY "주문번호"
) AS per_order;
