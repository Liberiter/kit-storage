-- runner: reset
-- 8장 «연습하기» exercise 1 해설: 글자로 적은 날짜 — 모양이 다른 줄을 찾아 고친 뒤 날짜로 견준다
SELECT code, created_on
FROM antipatterns.products
WHERE created_on NOT LIKE '____-__-__'
ORDER BY code;

UPDATE antipatterns.products
SET created_on = '2024-03-15'
WHERE created_on = '2024/03/15';

UPDATE antipatterns.products
SET created_on = '2024-04-02'
WHERE created_on = '24-04-02';

SELECT max(CAST(created_on AS date)) AS 최근등록일 FROM antipatterns.products;
