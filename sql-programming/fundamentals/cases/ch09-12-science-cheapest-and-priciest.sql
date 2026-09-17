-- 9.1 흔한 실수: 한 줄로 요약된 최저가와 최고가는 같은 책의 값이 아니다
-- (따라 하기 2단계가 낸 9,500원과 41,000원이 어느 책의 값인지 확인한다)
SELECT book_id AS 도서번호, title AS 제목, price AS 가격
FROM books
WHERE category = '과학' AND (price = 9500 OR price = 41000)
ORDER BY book_id;
