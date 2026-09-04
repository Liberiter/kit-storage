-- 3장 3.3 흔한 실수: 한 행의 category는 하나뿐이라 AND로 이으면 0행
SELECT title FROM books WHERE category = '여행' AND category = '요리';
