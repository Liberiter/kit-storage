-- 갱신 손실(lost update) 재현 — 세션 A.  (터미널 2에서는 lost_update_b.sql 을 띄웁니다)
-- 실행: ./concurrency.sh --terminal A lost-update [read-committed|repeatable-read]
-- 변수 iso(격리 수준)·book_id(대상 책)는 concurrency.sh 가 넘겨 줍니다.
\set ON_ERROR_STOP off
\echo
\echo '=== 세션 A — 갱신 손실 재현 (격리 수준: ':iso')'
\echo '    두 세션이 같은 재고를 읽고 각자 「읽은 값 - 1」을 씁니다. 두 권이 팔렸는데 재고는 한 권만 줄어드는지 봅니다.'
\echo
\echo '[A-1] 트랜잭션을 시작하고 재고를 읽습니다.'
BEGIN;
SET TRANSACTION ISOLATION LEVEL :iso;
SELECT stock FROM books WHERE book_id = :book_id \gset a_
\echo '      A가 읽은 재고: ':a_stock
\prompt '→ 터미널 2에서 [B-1]을 실행하고, 끝나면 여기서 Enter 를 누르세요 ' go1
\echo
\echo '[A-2] 읽은 값에서 1을 뺀 값을 씁니다 (A가 한 권 팔았습니다).'
UPDATE books SET stock = :a_stock - 1 WHERE book_id = :book_id;
\prompt '→ 터미널 2에서 [B-2]를 실행하세요. B의 UPDATE 는 A가 잠근 행을 기다리며 멈춥니다. 그 상태를 확인한 뒤 여기서 Enter 를 누르세요 ' go2
\echo
\echo '[A-3] 커밋합니다 — 이제 터미널 2의 UPDATE 가 풀립니다.'
COMMIT;
\prompt '→ 터미널 2에서 [B-3]까지 마친 뒤 여기서 Enter 를 누르세요 ' go3
\echo
\echo '[A-4] 최종 재고를 확인합니다. 두 권이 팔렸으니 처음보다 2 줄어야 합니다.'
SELECT stock AS final_stock FROM books WHERE book_id = :book_id;
\echo '      처음 읽은 값 ':a_stock' 과 비교해 보세요. 1만 줄었으면 갱신 손실입니다.'
\echo '      끝났으면 ./reset.sh 로 world 를 되돌리세요.'
