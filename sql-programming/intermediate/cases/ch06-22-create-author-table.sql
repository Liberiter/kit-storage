-- runner: reset
-- 6.2 practice 2 — 원장의 저자 이름만 담는 표를 만들고 채운다
CREATE TABLE ledger_authors (
    name text PRIMARY KEY
);

INSERT INTO ledger_authors (name)
SELECT "저자1"
FROM legacy.sales_ledger
WHERE "저자1" IS NOT NULL
UNION
SELECT "저자2"
FROM legacy.sales_ledger
WHERE "저자2" IS NOT NULL
UNION
SELECT "저자3"
FROM legacy.sales_ledger
WHERE "저자3" IS NOT NULL;

SELECT count(*) AS 저자수 FROM ledger_authors;
