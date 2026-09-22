-- runner: reset
-- 6.2 따라 하기 3단계 — 도서 표를 만들고 세 칸에서 모아 채운다
CREATE TABLE ledger_books (
    title text PRIMARY KEY,
    author text NOT NULL
);

INSERT INTO ledger_books (title, author)
SELECT "도서1", "저자1"
FROM legacy.sales_ledger
WHERE "도서1" IS NOT NULL
UNION
SELECT "도서2", "저자2"
FROM legacy.sales_ledger
WHERE "도서2" IS NOT NULL
UNION
SELECT "도서3", "저자3"
FROM legacy.sales_ledger
WHERE "도서3" IS NOT NULL;

SELECT count(*) AS 도서수 FROM ledger_books;
