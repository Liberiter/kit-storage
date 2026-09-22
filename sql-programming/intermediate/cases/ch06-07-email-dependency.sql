-- 6.1 따라 하기 5단계 — 이메일 하나에 이름·도시가 하나씩인지 확인한다
SELECT
    count(*) AS 이메일수,
    max(이름수) AS 최대이름수,
    max(도시수) AS 최대도시수
FROM (
    SELECT
        "고객이메일",
        count(DISTINCT "고객명") AS 이름수,
        count(DISTINCT "고객도시") AS 도시수
    FROM legacy.sales_ledger
    GROUP BY "고객이메일"
) AS per_email;
