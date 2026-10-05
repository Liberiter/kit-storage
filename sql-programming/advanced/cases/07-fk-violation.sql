-- runner: reset
-- kit smoke: 오류 케이스 — 없는 회원의 판매는 외래키가 거절한다 (오류 메시지와 [exit 3]). 거절된 INSERT 도
-- 힙에 죽은 행 버전을 남기므로(외래키 검사는 행을 넣은 뒤에 돈다) 변경형으로 돌린다.
INSERT INTO sales (sale_id, sold_at, account_id, book_id, store_id, channel, quantity, unit_price, status, receipt_no)
VALUES (1500001, '2026-09-01 10:00:00+09', 999999, 1, 1, 'web', 1, 15000, 'completed', 'R260901-1500001');
