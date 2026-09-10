-- 반복 불가능 읽기(nonrepeatable read) 재현 — 세션 B.  (터미널 1에서는 nonrepeatable_read_a.sql)
-- 실행: ./concurrency.sh --terminal B nonrepeatable-read [read-committed|repeatable-read]
\set ON_ERROR_STOP off
\echo
\echo '=== 세션 B — 반복 불가능 읽기 재현 (격리 수준: ':iso')'
\prompt '→ 터미널 1에서 [A-1]을 실행한 뒤 여기서 Enter 를 누르세요 ' go1
\echo
\echo '[B-1] 한 권을 팔고 바로 커밋합니다 (자동 커밋 — BEGIN 없이 실행한 문장은 곧바로 커밋됩니다).'
UPDATE books SET stock = stock - 1 WHERE book_id = :book_id;
\echo '      터미널 1로 돌아가 [A-2]를 실행하세요.'
