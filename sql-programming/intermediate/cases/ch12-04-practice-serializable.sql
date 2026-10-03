-- 12장 12.1 «practice» 1: 한 트랜잭션을 SERIALIZABLE로 열고 격리 수준과 1번 책 재고를 본다
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SHOW transaction_isolation;
SELECT stock FROM books WHERE book_id = 1;
COMMIT;
