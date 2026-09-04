-- 9.1 왜 그럴까요: 널인 행은 count(열)·min·max에서 모두 빠진다
SELECT
    count(*) AS 주문수,
    count(shipped_date) AS 발송한주문수,
    min(shipped_date) AS 첫발송일,
    max(shipped_date) AS 마지막발송일
FROM orders;
