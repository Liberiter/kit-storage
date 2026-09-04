-- runner: reset
-- 11.1 흔한 실수 — 값의 차례가 어긋나도 타입이 맞으면 조용히 들어간다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES ('빛나는 겨울 편지', '한지우', '소설', 232, 17000, '2026-08-20', 10);

SELECT title AS 제목, price AS 가격, page_count AS 쪽수
FROM books
WHERE title = '빛나는 겨울 편지';
