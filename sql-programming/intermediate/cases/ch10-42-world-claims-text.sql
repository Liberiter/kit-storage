-- 10장 주장 케이스 (글자) — 본문에 코드 블록으로 등장하지 않는다. 값이 글자·날짜라 정수 표와 나눴다.
-- UNION ALL 의 줄 차례는 보장되지 않으므로 주장 이름 차례로 늘어놓는다.
-- 뒷받침하는 자리:
--   240번 주문의 주문일·상태 → 10.1 «따라 하기» 3단계의 「5월에 들어온 240번 주문은 아직 배송준비 상태」
--   7번 고객의 가입일 → 10.3 «practice» 2 지문의 「2026년 2월에 가입한 7번 고객」
--   3번 직원의 부서·직급 → «연습하기» exercise 4 지문의 「물류 팀장인 3번」
--   책이 달리지 않는 분류의 이름 → «복습 exercise» 1 채점 포인트의 「「전체」·「문학」·「교양」·「실용」처럼」
SELECT '240번 주문의 주문일' AS 주장, CAST(order_date AS text) AS 실측값
FROM orders
WHERE order_id = 240
UNION ALL
SELECT '240번 주문의 상태', status FROM orders WHERE order_id = 240
UNION ALL
SELECT '3번 직원의 부서와 직급', department || ' ' || title
FROM staff
WHERE staff_id = 3
UNION ALL
SELECT '7번 고객의 가입일', CAST(signup_date AS text)
FROM customers
WHERE customer_id = 7
UNION ALL
SELECT '책이 달리지 않는 분류', string_agg(name, ',' ORDER BY name)
FROM categories
WHERE NOT EXISTS (SELECT 1 FROM books WHERE books.category = categories.name)
ORDER BY 주장;
