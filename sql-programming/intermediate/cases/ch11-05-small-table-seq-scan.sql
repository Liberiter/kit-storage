-- 11장 11.1 «왜 그럴까요»: 320줄의 books 는 기본키 조건에도 Seq Scan — 플래너가 싼 길을 고른다
EXPLAIN
SELECT book_id, title, price FROM books WHERE book_id = 12;
