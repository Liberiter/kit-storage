-- 5.2 practice 2 풀이 — 구매 인증이 없는 리뷰의 주문번호 자리를 0으로 채운다
SELECT review_id, rating, COALESCE(order_id, 0) AS "주문 번호"
FROM reviews
WHERE review_id BETWEEN 298 AND 303
ORDER BY review_id;
