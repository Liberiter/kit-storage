-- 3장 3.1 흔한 실수: 값에 작은따옴표를 빼면 열 이름으로 해석된다 (오류 기대)
SELECT title FROM books WHERE category = 여행 LIMIT 5;
