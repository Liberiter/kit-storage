-- 3장 exercise 3 해설: 날짜에서 작은따옴표를 빼면 열 이름이 아니라
-- 뺄셈 식(2025 - 1 - 1)으로 계산되어 date >= integer 오류가 난다 (오류 기대).
SELECT title, published_date
FROM books
WHERE published_date >= 2025-01-01 LIMIT 5;
