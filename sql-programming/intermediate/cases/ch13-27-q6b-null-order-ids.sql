-- 13장(exit assessment) 문항 6 (나) 해설: 서브쿼리가 내놓는 목록에 널이 섞였는지 세어 보기
SELECT count(*) AS 리뷰수, count(order_id) AS "주문번호가 있는 리뷰"
FROM reviews;
