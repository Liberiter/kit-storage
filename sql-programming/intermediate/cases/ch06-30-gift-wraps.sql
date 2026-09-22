-- runner: reset
-- 도전하기 problem 1 해설 — 포장 정보를 주문 표에 덧붙이지 않고 자기 표로 둔다
CREATE TABLE gift_wraps (
    order_id integer PRIMARY KEY REFERENCES orders (order_id),
    wrap_type text NOT NULL,
    wrap_fee integer NOT NULL
);

INSERT INTO gift_wraps (order_id, wrap_type, wrap_fee)
VALUES
    (1, '기본 포장', 2000),
    (3, '리본 포장', 3500);

SELECT
    gift_wraps.order_id AS 주문번호,
    orders.order_date AS 주문일,
    gift_wraps.wrap_type AS 포장종류,
    gift_wraps.wrap_fee AS 포장비
FROM gift_wraps
INNER JOIN orders ON gift_wraps.order_id = orders.order_id
ORDER BY gift_wraps.order_id;
