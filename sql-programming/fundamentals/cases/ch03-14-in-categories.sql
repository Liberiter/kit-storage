-- 3장 3.2 따라 하기 4단계: IN으로 값 목록 조건
SELECT title, category FROM books WHERE category IN ('여행', '요리') LIMIT 5;
