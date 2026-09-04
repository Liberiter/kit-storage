-- 9.1 따라 하기 3단계: avg의 결과는 소수점 아래가 길다
SELECT avg(price) AS 평균가격 FROM books WHERE category = '과학';
