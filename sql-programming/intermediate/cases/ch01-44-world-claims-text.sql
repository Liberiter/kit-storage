-- 1장이 산문으로 인용하는 world 의 날짜 주장. 값이 날짜라 정수 표와 타입이
-- 섞이므로 케이스를 나눴다 (주장 케이스 규약).
--   «도전하기» problem 1 해설의 「책숲의 가입 기록은 2026-08-04에서 끝난다」.
SELECT '가장 늦은 가입일 (customers.signup_date)' AS claim,
       (SELECT max(signup_date)::text FROM customers) AS value;
