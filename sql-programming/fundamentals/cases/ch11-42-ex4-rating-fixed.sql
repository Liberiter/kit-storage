-- runner: reset
-- exercise 4 해설 — 별점을 5로 고쳐 다시 넣는다
INSERT INTO reviews (book_id, customer_id, rating, review_date)
VALUES (7, 2, 5, '2026-08-21');

SELECT
    book_id AS 도서번호,
    customer_id AS 고객번호,
    rating AS 별점,
    COALESCE(comment, '(내용 없음)') AS "한 줄평"
FROM reviews
WHERE book_id = 7 AND customer_id = 2;
