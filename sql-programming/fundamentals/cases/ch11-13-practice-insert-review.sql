-- runner: reset
-- 11.1 practice 1 풀이 — 리뷰 한 건을 넣고 확인한다
INSERT INTO reviews (book_id, customer_id, rating, comment, review_date)
VALUES (5, 1, 5, '오랜만에 좋은 책', '2026-08-20');

SELECT book_id AS 도서번호, rating AS 별점, comment AS "한 줄평"
FROM reviews
WHERE book_id = 5 AND customer_id = 1;
