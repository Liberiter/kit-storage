-- 10.1 왜 그럴까요: 행이 하나도 없는 그룹의 평균은 널이다
SELECT avg(price) AS 평균가격 FROM books WHERE category = '만화';
