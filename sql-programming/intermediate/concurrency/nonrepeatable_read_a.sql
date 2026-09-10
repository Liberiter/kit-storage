-- 반복 불가능 읽기(nonrepeatable read) 재현 — 세션 A.  (터미널 2에서는 nonrepeatable_read_b.sql)
-- 실행: ./concurrency.sh --terminal A nonrepeatable-read [read-committed|repeatable-read]
\set ON_ERROR_STOP off
\echo
\echo '=== 세션 A — 반복 불가능 읽기 재현 (격리 수준: ':iso')'
\echo '    한 트랜잭션 안에서 같은 행을 두 번 읽는 사이에 다른 세션이 커밋하면 값이 달라지는지 봅니다.'
\echo
\echo '[A-1] 트랜잭션을 시작하고 재고를 읽습니다.'
BEGIN;
SET TRANSACTION ISOLATION LEVEL :iso;
SELECT stock AS first_read FROM books WHERE book_id = :book_id;
\prompt '→ 터미널 2에서 [B-1]을 실행하고, 끝나면 여기서 Enter 를 누르세요 ' go1
\echo
\echo '[A-2] 같은 트랜잭션 안에서 재고를 다시 읽습니다.'
SELECT stock AS second_read FROM books WHERE book_id = :book_id;
\echo '      READ COMMITTED 면 B의 커밋이 보여 값이 1 줄어 있습니다 — 반복 불가능 읽기.'
\echo '      REPEATABLE READ 면 트랜잭션이 시작할 때의 값이 그대로 보입니다.'
COMMIT;
\echo '      끝났으면 ./reset.sh 로 world 를 되돌리세요.'
