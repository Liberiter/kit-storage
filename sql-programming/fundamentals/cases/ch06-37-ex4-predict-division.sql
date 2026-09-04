-- exercise 4 해설: 예상을 먼저 적고 대조하는 문제 (S1.3)
SELECT
    41000 / 1000 AS 가,
    41500 / 1000 AS 나,
    CAST(41500 AS numeric) / 1000 AS 다,
    round(CAST(41500 AS numeric) / 1000, 1) AS 라;
