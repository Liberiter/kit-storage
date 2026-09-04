-- 5장 본문이 인용하는 날짜 주장. 각 행이 "주장 → 실측값(날짜 글자)" 쌍이다.
-- 값이 정수가 아니라 날짜라 수치 주장(ch05-37-world-claims-counts)에서 나눴다
-- (pipeline "주장 케이스" — 값의 타입이 섞이면 케이스를 나눈다). 본문이 적는
-- 표기 그대로 YYYY-MM-DD 글자로 뽑아 문장과 바로 대조할 수 있게 한다.
--  · exercise 2 해설: 가장 이른 생일 1962-03-10
--  · 복습 exercise: 가장 늦은 발송일 2026-08-22
--  · problem 1: 발송 대기 주문 중 가장 이른 주문일 2024-03-07
SELECT '가장 늦은 발송일' AS claim,
       (SELECT CAST(max(shipped_date) AS text) FROM orders) AS value
UNION ALL
SELECT '발송 대기 주문 중 가장 이른 주문일',
       (SELECT CAST(min(order_date) AS text) FROM orders
         WHERE shipped_date IS NULL AND status <> '취소')
UNION ALL
SELECT '가장 이른 생일',
       (SELECT CAST(min(birth_date) AS text) FROM customers);
