-- 3장 3.3 따라 하기 2단계: OR (ch03-14의 IN 질의와 출력이 같아야 한다)
SELECT title, category
FROM books
WHERE category = '여행' OR category = '요리' LIMIT 5;
