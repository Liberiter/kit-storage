-- runner: reset
-- 11.1 개념 — 서식 규칙 R42의 예제. 본문은 출력을 싣지 않는다
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES
    ('조용한 아침 노트', '오서연', '에세이', 15500, 208, '2026-08-22', 8),
    ('다시 쓰는 커피 사전', '권민준', '요리', 21000, 264, '2026-08-25', 12);
