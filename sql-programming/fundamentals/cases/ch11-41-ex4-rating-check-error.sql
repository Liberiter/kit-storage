-- runner: reset
-- exercise 4 해설 — 별점 6점은 CHECK 제약이 막는다 (오류 기대)
INSERT INTO reviews (book_id, customer_id, rating, review_date)
VALUES (7, 2, 6, '2026-08-21');
