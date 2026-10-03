-- 12장 12.1 «흔한 실수» 1: 트랜잭션 안에서 질의를 한 뒤에는 격리 수준을 바꿀 수 없다 (오류 기대)
BEGIN;
SELECT stock FROM books WHERE book_id = 1;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
ROLLBACK;
