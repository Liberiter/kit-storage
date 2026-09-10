-- legacy.sql — 정규화 실습용 비정규 원장 (스키마 legacy, 6장).
-- 책숲이 데이터베이스를 쓰기 전 스프레드시트로 관리하던 「판매 원장」을 옮겨 온 모양새다:
-- 주문 한 건이 한 줄이고, 고객 정보가 줄마다 반복되고, 책은 1~3번 칸에 가로로 늘어서고,
-- 모든 칸이 글자(text)다. 2025년 주문 가운데 책이 3종 이하인 것을 world 의 주문에서
-- 유도한다 (난수 없음 — 적재할 때마다 같다). 본 world(public)와는 별도 스키마에 두며,
-- 실습에서 마음껏 고치고 지워도 된다 — ./reset.sh 가 다시 만든다.

SET client_min_messages = warning;

CREATE SCHEMA legacy;

CREATE TABLE legacy.sales_ledger (
    "주문번호"   text,
    "주문일"     text,
    "고객명"     text,
    "고객이메일" text,
    "고객도시"   text,
    "도서1"      text,
    "저자1"      text,
    "단가1"      text,
    "수량1"      text,
    "도서2"      text,
    "저자2"      text,
    "단가2"      text,
    "수량2"      text,
    "도서3"      text,
    "저자3"      text,
    "단가3"      text,
    "수량3"      text,
    "상태"       text,
    "발송일"     text
);

WITH numbered AS (
  SELECT oi.order_id, oi.book_id, oi.quantity, oi.unit_price,
         row_number() OVER (PARTITION BY oi.order_id ORDER BY oi.book_id) AS pos,
         count(*)     OVER (PARTITION BY oi.order_id) AS n_items
    FROM order_items oi
),
eligible AS (
  SELECT o.order_id
    FROM orders o
   WHERE o.order_date BETWEEN '2025-01-01' AND '2025-12-31'
     AND (SELECT max(n_items) FROM numbered WHERE order_id = o.order_id) <= 3
)
INSERT INTO legacy.sales_ledger
SELECT 'ORD-' || lpad(o.order_id::text, 5, '0'),
       to_char(o.order_date, 'YYYY.MM.DD'),
       c.name,
       c.email,
       c.city,
       max(b.title)                    FILTER (WHERE n.pos = 1),
       max(b.author)                   FILTER (WHERE n.pos = 1),
       max(to_char(n.unit_price, 'FM999,999') || '원') FILTER (WHERE n.pos = 1),
       max(n.quantity::text)           FILTER (WHERE n.pos = 1),
       max(b.title)                    FILTER (WHERE n.pos = 2),
       max(b.author)                   FILTER (WHERE n.pos = 2),
       max(to_char(n.unit_price, 'FM999,999') || '원') FILTER (WHERE n.pos = 2),
       max(n.quantity::text)           FILTER (WHERE n.pos = 2),
       max(b.title)                    FILTER (WHERE n.pos = 3),
       max(b.author)                   FILTER (WHERE n.pos = 3),
       max(to_char(n.unit_price, 'FM999,999') || '원') FILTER (WHERE n.pos = 3),
       max(n.quantity::text)           FILTER (WHERE n.pos = 3),
       o.status,
       to_char(o.shipped_date, 'YYYY.MM.DD')
  FROM eligible e
  JOIN orders o USING (order_id)
  JOIN customers c USING (customer_id)
  JOIN numbered n USING (order_id)
  JOIN books b ON b.book_id = n.book_id
 GROUP BY o.order_id, o.order_date, c.name, c.email, c.city, o.status, o.shipped_date
 ORDER BY o.order_id;
