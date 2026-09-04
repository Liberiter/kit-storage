-- 9.1 흔한 실수: 평균을 직접 만들면 6장의 정수 나눗셈 함정에 걸린다
SELECT sum(price) / count(*) AS 직접계산, avg(price) AS 함수계산 FROM books;
