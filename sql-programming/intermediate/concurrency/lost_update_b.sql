-- 갱신 손실(lost update) 재현 — 세션 B.  (터미널 1에서는 lost_update_a.sql 을 띄웁니다)
-- 실행: ./concurrency.sh --terminal B lost-update [read-committed|repeatable-read]
\set ON_ERROR_STOP off
\echo
\echo '=== 세션 B — 갱신 손실 재현 (격리 수준: ':iso')'
\prompt '→ 터미널 1에서 [A-1]을 실행한 뒤 여기서 Enter 를 누르세요 ' go1
\echo
\echo '[B-1] 트랜잭션을 시작하고 재고를 읽습니다 (A는 아직 커밋하지 않았습니다).'
BEGIN;
SET TRANSACTION ISOLATION LEVEL :iso;
SELECT stock FROM books WHERE book_id = :book_id \gset b_
\echo '      B가 읽은 재고: ':b_stock
\prompt '→ 터미널 1에서 [A-2]를 실행한 뒤 여기서 Enter 를 누르세요 ' go2
\echo
\echo '[B-2] 읽은 값에서 1을 뺀 값을 씁니다 (B도 한 권 팔았습니다).'
\echo '      A가 같은 행을 잠그고 있어 이 문장은 A가 커밋할 때까지 멈춥니다 — 터미널 1에서 [A-3]을 실행하세요.'
UPDATE books SET stock = :b_stock - 1 WHERE book_id = :book_id;
\echo '      (READ COMMITTED 면 UPDATE 1 — B가 A의 결과를 덮어씁니다. REPEATABLE READ 면 could not serialize access 오류로 거절됩니다.)'
\echo
\echo '[B-3] 커밋합니다 (오류가 났다면 ROLLBACK 으로 끝납니다).'
COMMIT;
\echo '      터미널 1로 돌아가 [A-4]를 실행하세요.'
