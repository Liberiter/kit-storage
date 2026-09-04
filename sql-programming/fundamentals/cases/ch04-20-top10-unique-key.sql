-- 4장 4.2 왜 그럴까요: 같은 정렬로 LIMIT 10 — 앞 5줄이 ch04-19와 한 글자도 다르지 않다
SELECT title, price FROM books ORDER BY price DESC, book_id LIMIT 10;
