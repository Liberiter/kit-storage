-- runner: reset
-- 11.1 따라 하기 4단계 — 이미 쓰이고 있는 기본키 값은 막힌다 (오류 기대)
INSERT INTO books (
    book_id, title, author, category, price, page_count, published_date, stock
)
VALUES (1, '빛나는 계절', '한지우', '에세이', 17000, 232, '2026-08-20', 10);
