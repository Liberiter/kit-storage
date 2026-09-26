-- 8장 «연습하기» exercise 2 해설: 부동소수점 금액 — 같음 비교가 맞는 값과 틀리는 값
SELECT code, price FROM antipatterns.products WHERE price = 18000.5;

SELECT code, price FROM antipatterns.products WHERE price = 22000.1;
