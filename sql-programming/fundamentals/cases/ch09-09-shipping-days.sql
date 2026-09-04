-- 9.1 왜 그럴까요: 평균의 분모는 전체 행 수가 아니라 값이 있는 행 수다
-- (849 ÷ 476 = 1.78. 6장의 날짜 뺄셈을 다시 쓴다)
SELECT
    count(shipped_date - order_date) AS 계산된주문수,
    sum(shipped_date - order_date) AS 소요일합계,
    round(avg(shipped_date - order_date), 2) AS 평균소요일
FROM orders;
