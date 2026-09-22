-- runner: reset
-- 도전하기 problem 2 해설 — 복합 기본키가 같은 (주문, 도서) 짝을 막는다 (오류 기대)
CREATE TABLE trial_order_items (
    order_no text NOT NULL,
    title text NOT NULL,
    quantity integer NOT NULL,
    PRIMARY KEY (order_no, title)
);

INSERT INTO trial_order_items (order_no, title, quantity)
VALUES ('ORD-00001', '작은 별자리', 1);

INSERT INTO trial_order_items (order_no, title, quantity)
VALUES ('ORD-00001', '작은 별자리', 2);
