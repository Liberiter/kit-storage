-- 6.2 따라 하기 3단계: :: 표기는 CAST와 같은 일을 한다
-- ch06-16과 기대 출력이 바이트 동일해야 한다 (D-022)
SELECT title, price, price::numeric / 1000 AS "천 원 단위"
FROM books
ORDER BY book_id
LIMIT 5;
