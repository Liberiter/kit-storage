-- runner: reset
-- 11.1 왜 그럴까요 — CHECK 제약을 어기는 값은 막힌다 (오류 기대)
INSERT INTO books (
    title, author, category, price, page_count, published_date, stock
)
VALUES ('빛나는 계절', '한지우', '에세이', 0, 232, '2026-08-20', 10);
