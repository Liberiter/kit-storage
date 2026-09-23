-- runner: reset
-- 7장 «복습 exercise» 2 해설 (6장 — 스키마 설계): 공급사 표와 공급 제안 표
CREATE TABLE suppliers (
    supplier_code text PRIMARY KEY,
    name text NOT NULL,
    contact_email text NOT NULL UNIQUE
);

CREATE TABLE supplier_offers (
    supplier_code text NOT NULL REFERENCES suppliers (supplier_code),
    book_id integer NOT NULL REFERENCES books (book_id),
    supplier_price integer NOT NULL CHECK (supplier_price > 0),
    offered_on date NOT NULL,
    PRIMARY KEY (supplier_code, book_id)
);

INSERT INTO suppliers (supplier_code, name, contact_email)
VALUES
    ('SUP-001', '한빛도서유통', 'order@hanbit-dist.example'),
    ('SUP-002', '새벽책배송', 'help@dawnbooks.example');

INSERT INTO supplier_offers (supplier_code, book_id, supplier_price, offered_on)
VALUES
    ('SUP-001', 1, 9800, '2026-09-08'),
    ('SUP-002', 1, 9500, '2026-09-08');

SELECT
    supplier_offers.book_id AS 도서번호,
    suppliers.name AS 공급사,
    supplier_offers.supplier_price AS 공급가
FROM supplier_offers
INNER JOIN suppliers
    ON supplier_offers.supplier_code = suppliers.supplier_code
ORDER BY supplier_offers.supplier_price;
