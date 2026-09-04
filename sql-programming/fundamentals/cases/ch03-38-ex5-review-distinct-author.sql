-- 3장 복습 exercise(2장) 해설: 여행 분야 3만 원 이상 도서의 저자를 중복 없이
SELECT DISTINCT author AS 저자
FROM books
WHERE category = '여행' AND price >= 30000;
