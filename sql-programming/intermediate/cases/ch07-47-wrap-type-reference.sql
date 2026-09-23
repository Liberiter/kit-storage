-- runner: reset
-- 7장 «도전하기» problem 3 해설: 값의 종류를 참조 표와 외래키로 못 박는다 (오류 기대)
CREATE TABLE wrap_types (
    wrap_type text PRIMARY KEY
);

INSERT INTO wrap_types (wrap_type)
VALUES
    ('기본 포장'),
    ('리본 포장');

CREATE TABLE gift_wraps (
    order_id integer PRIMARY KEY REFERENCES orders (order_id),
    wrap_type text NOT NULL REFERENCES wrap_types (wrap_type),
    wrap_fee integer NOT NULL CHECK (wrap_fee >= 0)
);

INSERT INTO gift_wraps (order_id, wrap_type, wrap_fee)
VALUES (1, '기본 포장', 2000);

SELECT order_id AS 주문번호, wrap_type AS 포장종류, wrap_fee AS 포장비
FROM gift_wraps
ORDER BY order_id;

INSERT INTO gift_wraps (order_id, wrap_type, wrap_fee)
VALUES (3, '리븐 포장', 3500);
