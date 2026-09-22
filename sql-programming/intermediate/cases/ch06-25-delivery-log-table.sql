-- runner: reset
-- 연습하기 exercise 3 지문 — 물류 업체에서 받은 배송 기록 표. 본문은 출력을 싣지 않는다
CREATE TABLE delivery_log (
    delivery_no text PRIMARY KEY,
    order_no text NOT NULL,
    courier_name text NOT NULL,
    courier_phone text NOT NULL,
    delivered_on date NOT NULL
);
