-- 3장 3.3 흔한 실수: OR 뒤에 값만 적으면 조건이 아니다 (오류 기대)
SELECT title, category FROM books WHERE category = '여행' OR '요리';
