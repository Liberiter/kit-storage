-- 6.3 따라 하기 1단계: round로 소수점 자리를 다듬는다
SELECT title, price, round(CAST(price AS numeric) / 1000, 1) AS "천 원 단위"
FROM books
ORDER BY book_id
LIMIT 5;
