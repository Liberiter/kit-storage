-- 9.1 따라 하기 3단계: 6장의 round로 소수점 아래 한 자리까지 다듬는다
SELECT round(avg(price), 1) AS 평균가격 FROM books WHERE category = '과학';
