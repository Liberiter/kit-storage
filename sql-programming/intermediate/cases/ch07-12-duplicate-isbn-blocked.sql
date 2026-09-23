-- runner: reset
-- 7장 7.1 «흔한 실수»: 다른 책의 ISBN 을 가져다 쓰면 UNIQUE 가 막는다 (오류 기대)
UPDATE book_meta SET isbn13 = '979-11-07919-729-1' WHERE book_id = 2;
