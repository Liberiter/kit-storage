-- 6.2 따라 하기 2단계: books에 형변환을 적용한다
SELECT title, price, CAST(price AS numeric) / 1000 AS "천 원 단위"
FROM books
ORDER BY book_id
LIMIT 5;
