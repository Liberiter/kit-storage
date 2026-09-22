-- runner: reset
-- 6.2 practice 1 — 원장의 상태 값만 담는 작은 표를 만들고 채운다
CREATE TABLE ledger_statuses (
    status text PRIMARY KEY
);

INSERT INTO ledger_statuses (status)
SELECT DISTINCT "상태"
FROM legacy.sales_ledger;

SELECT status AS 상태 FROM ledger_statuses ORDER BY status;
