-- 6.1 흔한 실수: 정수끼리 나누면 소수점이 버려진다
SELECT title, price, price / 1000 AS "천 원 단위"
FROM books
ORDER BY book_id
LIMIT 5;
