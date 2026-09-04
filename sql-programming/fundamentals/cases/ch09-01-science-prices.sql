-- 9.1 문제 상황: 과학 분야 책값을 눈으로 훑어서는 평균을 낼 수 없다
SELECT price AS 가격 FROM books WHERE category = '과학' ORDER BY price LIMIT 5;
