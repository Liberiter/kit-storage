-- 8장 8.1 «왜 그럴까요»: 부동소수점 금액 — 적은 값으로 찾으면 못 찾고, 담긴 값·수치형 변환·같은 근삿값이 되는 다른 값
SELECT code, price FROM antipatterns.products WHERE price = 15999.99;

SELECT
    code,
    price,
    CAST(price AS double precision) AS 담긴값,
    CAST(price AS numeric) AS 수치형으로
FROM antipatterns.products
WHERE code IN ('BK-001', 'BK-010')
ORDER BY code;

SELECT
    CAST(15999.9903 AS real) AS 찍히는값,
    CAST(15999.9903 AS real) = CAST(15999.99 AS real) AS 같은값인가;
