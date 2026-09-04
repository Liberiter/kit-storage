-- 3장 3.3 따라 하기 4단계: 조건 세 개를 AND로 잇고 줄을 나눈 형태
SELECT title, price
FROM books
WHERE category = '여행'
    AND price BETWEEN 10000 AND 25000
    AND title LIKE '%제주%';
