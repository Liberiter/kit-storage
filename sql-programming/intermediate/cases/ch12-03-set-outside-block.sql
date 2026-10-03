-- 12장 12.1 «흔한 실수» 2: BEGIN 없이 SET TRANSACTION을 보내면 경고만 나고 아무것도 바뀌지 않는다
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SHOW transaction_isolation;
