-- 8장 주장 케이스 (소수) — 본문에 코드 블록으로 등장하지 않는다.
-- 값이 소수라 정수·글자·불리언 표와 타입이 섞이므로 따로 뒀다. 뒷받침하는 자리:
--   BK-004·BK-010 의 가격을 psql 로 조회하면 찍히는 값 → «연습하기» exercise 2 지문의
--     「각각 18000.5 와 22000.1 로 찍힙니다」 (real 열을 그대로 뽑아 psql 이 찍는 모양을 고정한다)
SELECT 'BK-004 의 가격' AS 주장, price AS 실측값
FROM antipatterns.products WHERE code = 'BK-004'
UNION ALL
SELECT 'BK-010 의 가격', price
FROM antipatterns.products WHERE code = 'BK-010';
