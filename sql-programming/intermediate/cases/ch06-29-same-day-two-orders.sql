-- 복습 exercise 2 해설 (2장) — 같은 고객이 같은 날 두 번 주문한 자리 (셀프 조인)
SELECT
    earlier."고객명" AS 고객명,
    earlier."주문일" AS 주문일,
    earlier."주문번호" AS 앞주문,
    later."주문번호" AS 뒤주문
FROM legacy.sales_ledger AS earlier
INNER JOIN legacy.sales_ledger AS later
    ON earlier."고객이메일" = later."고객이메일"
    AND earlier."주문일" = later."주문일"
    AND earlier."주문번호" < later."주문번호"
ORDER BY earlier."주문번호";
