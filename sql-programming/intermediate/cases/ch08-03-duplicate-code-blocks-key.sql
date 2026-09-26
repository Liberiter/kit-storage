-- runner: reset
-- 8장 8.1 «따라 하기» 1단계: code 가 겹치는 자리를 세고, 기본키를 걸어 본다 (막힌다)
SELECT code, count(*) AS 줄수
FROM antipatterns.products
GROUP BY code
HAVING count(*) > 1;

ALTER TABLE antipatterns.products
ADD CONSTRAINT products_code_pkey PRIMARY KEY (code);
