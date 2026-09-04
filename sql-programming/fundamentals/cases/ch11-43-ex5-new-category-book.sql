-- runner: reset
-- 복습 exercise 5(2장) 해설 — 새 분야 책을 넣고 DISTINCT로 분야를 본다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES ('오늘의 꼬마 화가', '신유나', '만화', 13000, 120, '2026-09-05', 15);

SELECT DISTINCT category AS 분야 FROM books ORDER BY 분야;
