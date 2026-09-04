-- runner: reset
-- 11.1 practice 2 풀이 — 책 두 권을 한 문장으로 넣는다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES
    ('작은 별나라 연습', '임하윤', '어린이', 12000, 96, '2026-09-01', 30),
    ('처음 만나는 항해 기록', '조건우', '역사', 26500, 344, '2026-09-03', 6);

SELECT title AS 제목, category AS 분야, price AS 가격, stock AS 재고
FROM books
WHERE title IN ('작은 별나라 연습', '처음 만나는 항해 기록')
ORDER BY title;
