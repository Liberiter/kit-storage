-- 10.2 문제 상황: 리뷰를 10건 이상 쓴 손님 명단
SELECT customer_id AS 고객번호
FROM reviews
GROUP BY customer_id
HAVING count(*) >= 10
ORDER BY 고객번호;
