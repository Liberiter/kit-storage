-- runner: reset
-- 연습하기 exercise 4 해설 — 고객마다 주문 수를 미리 세어 담는 요약 표
CREATE TABLE ledger_customer_summary (
    email text PRIMARY KEY,
    order_count integer NOT NULL
);

INSERT INTO ledger_customer_summary (email, order_count)
SELECT "고객이메일", count(*)
FROM legacy.sales_ledger
GROUP BY "고객이메일";

SELECT email AS 이메일, order_count AS 주문수
FROM ledger_customer_summary
ORDER BY order_count DESC, email
LIMIT 5;
