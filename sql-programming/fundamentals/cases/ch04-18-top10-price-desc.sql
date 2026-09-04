-- 4장 4.2 왜 그럴까요: LIMIT 10의 앞 5줄이 LIMIT 5(ch04-15)와 다르다 — 동점 세 권의 순서
SELECT title, price FROM books ORDER BY price DESC LIMIT 10;
