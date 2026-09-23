-- runner: reset
-- 7장 «도전하기» problem 2 해설: 같은 사람의 같은 책 리뷰는 새로 넣지 않고 고친다
INSERT INTO reviews (book_id, customer_id, rating, comment, review_date)
VALUES (36, 48, 5, '다시 읽고 별점을 올렸습니다.', '2026-09-08')
ON CONFLICT (book_id, customer_id) DO UPDATE
SET rating = EXCLUDED.rating,
    comment = EXCLUDED.comment,
    review_date = EXCLUDED.review_date
RETURNING
    review_id,
    OLD.rating AS 예전별점,
    NEW.rating AS 새별점,
    OLD.review_date AS 예전날짜,
    NEW.review_date AS 새날짜;

SELECT count(*) AS 리뷰수 FROM reviews;
