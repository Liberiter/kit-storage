-- runner: reset
-- 11.2 왜 그럴까요 — WHERE를 빠뜨린 UPDATE는 모든 행을 고친다
UPDATE books SET price = 17500;

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가 FROM books;
