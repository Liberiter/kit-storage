-- 7.2 practice 1 풀이 (1): 리뷰 301번이 가리키는 번호들
SELECT review_id, book_id, customer_id, order_id
FROM reviews
WHERE review_id = 301;
