-- 시나리오: 긴 트랜잭션이 뒷정리를 막는다 — 오래된 스냅숏을 쥔 트랜잭션이 열려 있는 동안 VACUUM 은 그
-- 스냅숏이 볼 수도 있는 옛 행 버전을 지우지 못한다.
-- 실행: ./sessions.sh scenarios/long-transaction-vacuum.sql
-- 재료: books 의 앞 100권. 죽은 행 버전의 수는 pgstattuple 로 센다.

-- @A
-- A가 REPEATABLE READ 트랜잭션을 열고 books를 한 번 읽습니다. 이 순간의 스냅숏이 트랜잭션 끝까지 남습니다.
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT count(*) AS books FROM books;

-- @B
-- B가 앞 100권의 가격을 고칩니다 (자동 커밋). 옛 행 버전 100개가 남습니다.
UPDATE books SET price = price + 100 WHERE book_id <= 100;

-- @B
-- B가 뒷정리를 돌립니다. A의 스냅숏이 옛 버전을 볼 수 있어 지우지 못합니다.
VACUUM books;
SELECT tuple_count, dead_tuple_count FROM pgstattuple('books');

-- @A
-- A의 스냅숏으로는 여전히 고치기 전 가격이 보입니다.
SELECT sum(price) AS price_sum_seen_by_a FROM books WHERE book_id <= 100;
COMMIT;

-- @B
-- A가 끝났으니 다시 뒷정리를 돌립니다. 이번에는 옛 버전이 지워집니다.
VACUUM books;
SELECT tuple_count, dead_tuple_count FROM pgstattuple('books');

-- @expect A ok
-- @expect B ok
