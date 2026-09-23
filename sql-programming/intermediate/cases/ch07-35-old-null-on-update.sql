-- runner: reset
-- 7장 7.3 «흔한 실수»: 널을 담을 수 있는 열을 OLD 로 집으면 고친 줄도 널이다
INSERT INTO reviews (book_id, customer_id, rating, comment, review_date)
VALUES (187, 1, 4, '다시 읽고 고쳐 씁니다.', '2026-09-08')
ON CONFLICT (book_id, customer_id) DO UPDATE
SET rating = EXCLUDED.rating,
    comment = EXCLUDED.comment,
    review_date = EXCLUDED.review_date
RETURNING review_id, OLD.comment AS 예전평, OLD.rating AS 예전별점;
