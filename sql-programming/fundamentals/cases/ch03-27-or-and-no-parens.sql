-- 3장 3.3 왜 그럴까요: 괄호 없이 OR와 AND를 섞은 질의 (AND가 먼저 묶인다)
-- style.md R12(괄호로 우선순위를 드러낸다)의 근거가 되는 의도된 반례다.
SELECT title, category, price
FROM books
WHERE category = '여행' OR category = '요리' AND price <= 10000 LIMIT 5;
