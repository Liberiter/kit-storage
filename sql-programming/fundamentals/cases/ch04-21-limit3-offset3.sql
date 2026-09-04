-- 4장 4.2 흔한 실수: OFFSET 3은 3행을 건너뛴다 — 결과는 4~6위다
SELECT title, price FROM books ORDER BY price DESC, book_id LIMIT 3 OFFSET 3;
