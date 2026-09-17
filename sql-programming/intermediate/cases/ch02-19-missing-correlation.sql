-- 2장 2.2 «흔한 실수» — 상관 조건을 빠뜨리면 모든 행이 같은 답을 받는다
SELECT count(*) AS "EXISTS 로 센 권수"
FROM books
WHERE EXISTS (SELECT 1 FROM reviews);

SELECT count(*) AS "NOT EXISTS 로 센 권수"
FROM books
WHERE NOT EXISTS (SELECT 1 FROM reviews);
