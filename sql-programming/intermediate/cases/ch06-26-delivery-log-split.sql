-- runner: reset
-- 연습하기 exercise 3 해설 — 택배 기사 정보를 자기 표로 옮겨 이행 종속을 없앤다
CREATE TABLE couriers (
    name text PRIMARY KEY,
    phone text NOT NULL
);

CREATE TABLE delivery_log (
    delivery_no text PRIMARY KEY,
    order_no text NOT NULL,
    courier_name text NOT NULL REFERENCES couriers (name),
    delivered_on date NOT NULL
);

INSERT INTO couriers (name, phone)
VALUES
    ('박도윤', '010-2000-3001'),
    ('최서연', '010-2000-3002');

INSERT INTO delivery_log (delivery_no, order_no, courier_name, delivered_on)
VALUES
    ('DLV-0001', 'ORD-00001', '박도윤', '2025-09-16'),
    ('DLV-0002', 'ORD-00003', '박도윤', '2025-01-12');

SELECT
    delivery_log.delivery_no AS 배송번호,
    delivery_log.courier_name AS 기사,
    couriers.phone AS 전화,
    delivery_log.delivered_on AS 배송일
FROM delivery_log
INNER JOIN couriers ON delivery_log.courier_name = couriers.name
ORDER BY delivery_log.delivery_no;
