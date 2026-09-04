-- runner: reset
-- 11.1 왜 그럴까요 — NOT NULL 열을 빠뜨리면 막힌다 (오류 기대)
INSERT INTO books (title, author, category, price, page_count)
VALUES ('빛나는 계절', '한지우', '에세이', 17000, 232);
