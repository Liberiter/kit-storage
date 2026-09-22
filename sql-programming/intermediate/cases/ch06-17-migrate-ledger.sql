-- runner: reset
-- 6.2 따라 하기 4단계 — 원장을 네 표로 옮기는 스크립트 전체와 세 가지 확인
CREATE TABLE ledger_customers (
    email text PRIMARY KEY,
    name text NOT NULL,
    city text NOT NULL
);

INSERT INTO ledger_customers (email, name, city)
SELECT DISTINCT "고객이메일", "고객명", "고객도시"
FROM legacy.sales_ledger;

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

CREATE TABLE ledger_orders (
    order_no text PRIMARY KEY,
    order_date date NOT NULL,
    customer_email text NOT NULL REFERENCES ledger_customers (email),
    status text NOT NULL,
    shipped_date date
);

INSERT INTO ledger_orders (
    order_no, order_date, customer_email, status, shipped_date
)
SELECT
    "주문번호",
    CAST("주문일" AS date),
    "고객이메일",
    "상태",
    CAST("발송일" AS date)
FROM legacy.sales_ledger;

CREATE TABLE ledger_order_items (
    order_no text NOT NULL REFERENCES ledger_orders (order_no),
    title text NOT NULL REFERENCES ledger_books (title),
    quantity integer NOT NULL,
    unit_price integer NOT NULL,
    PRIMARY KEY (order_no, title)
);

INSERT INTO ledger_order_items (order_no, title, quantity, unit_price)
SELECT
    "주문번호",
    "도서1",
    CAST("수량1" AS integer),
    CAST(replace(replace("단가1", ',', ''), '원', '') AS integer)
FROM legacy.sales_ledger
WHERE "도서1" IS NOT NULL;

INSERT INTO ledger_order_items (order_no, title, quantity, unit_price)
SELECT
    "주문번호",
    "도서2",
    CAST("수량2" AS integer),
    CAST(replace(replace("단가2", ',', ''), '원', '') AS integer)
FROM legacy.sales_ledger
WHERE "도서2" IS NOT NULL;

INSERT INTO ledger_order_items (order_no, title, quantity, unit_price)
SELECT
    "주문번호",
    "도서3",
    CAST("수량3" AS integer),
    CAST(replace(replace("단가3", ',', ''), '원', '') AS integer)
FROM legacy.sales_ledger
WHERE "도서3" IS NOT NULL;

SELECT
    (SELECT count(*) FROM ledger_customers) AS 고객,
    (SELECT count(*) FROM ledger_books) AS 도서,
    (SELECT count(*) FROM ledger_orders) AS 주문,
    (SELECT count(*) FROM ledger_order_items) AS 항목,
    (SELECT sum(quantity * unit_price) FROM ledger_order_items) AS 총매출;

\d ledger_order_items

SELECT
    ledger_orders.order_no AS 주문번호,
    ledger_customers.name AS 고객명,
    ledger_books.title AS 도서,
    ledger_order_items.quantity AS 수량,
    ledger_order_items.unit_price AS 단가
FROM ledger_orders
INNER JOIN ledger_customers
    ON ledger_orders.customer_email = ledger_customers.email
INNER JOIN ledger_order_items
    ON ledger_orders.order_no = ledger_order_items.order_no
INNER JOIN ledger_books ON ledger_order_items.title = ledger_books.title
WHERE ledger_orders.order_no = 'ORD-00001'
ORDER BY ledger_books.title;
