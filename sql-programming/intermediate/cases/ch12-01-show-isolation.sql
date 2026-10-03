-- 12장 12.1 «따라 하기» 1단계: 기본 격리 수준을 보고, 한 트랜잭션만 REPEATABLE READ로 바꾼 뒤 다시 본다
SHOW transaction_isolation;

BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
COMMIT;

SHOW transaction_isolation;
