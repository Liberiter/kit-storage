-- runner: reset
-- 11.1 따라 하기 2단계 — 여러 행을 한 문장으로 넣는다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES
    ('조용한 아침 노트', '오서연', '에세이', 15500, 208, '2026-08-22', 8),
    ('다시 쓰는 커피 사전', '권민준', '요리', 21000, 264, '2026-08-25', 12);

SELECT title AS 제목, category AS 분야, price AS 가격, stock AS 재고
FROM books
WHERE title IN ('조용한 아침 노트', '다시 쓰는 커피 사전')
ORDER BY title;
