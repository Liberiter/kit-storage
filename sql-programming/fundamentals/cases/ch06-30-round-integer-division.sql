-- 6.3 흔한 실수: 정수끼리 나눈 뒤에 round를 걸면 오류 없이 결과가 틀린다
SELECT title, price, round(price / 1000, 1) AS "천 원 단위"
FROM books
ORDER BY book_id
LIMIT 5;
