-- 5.2 따라 하기 3단계 — COALESCE의 규칙을 짧은 식으로 확인한다
SELECT
    COALESCE(NULL, '두 번째 값') AS "첫째가 NULL일 때",
    COALESCE('첫 번째 값', '두 번째 값') AS "첫째가 값일 때";
