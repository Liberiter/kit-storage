-- 동료가 쓴 검토 대상 4 — 매장 간 재고 이동 처리
-- 작성: 물류팀 임수빈 매니저 / 검토 요청: "테스트에서는 잘 됐습니다. 여러 직원이 동시에 써도 괜찮을까요?"
-- 앱은 기본 격리 수준(READ COMMITTED)으로 아래 차례를 실행한다. 이 파일은 그 차례를 세션 하나로 한 번
-- 따라 해 본 것이다 (그대로 실행된다. ./reset.sh 가 되돌린다).

CREATE SCHEMA IF NOT EXISTS peer;
CREATE TABLE IF NOT EXISTS peer.transfer_log (
    request_id text,
    book_id    integer,
    moved      integer,
    logged_at  timestamptz DEFAULT now()
);

-- [1] 같은 요청이 두 번 처리되지 않게, 로그에 요청 번호가 있는지 먼저 본다 (0 이면 진행)
SELECT count(*) AS already_done FROM peer.transfer_log WHERE request_id = 'T-1001';

-- [2] 이동 처리
BEGIN;
-- 앱이 1번 책의 재고를 읽어 둔다 (예: 5)
SELECT stock FROM books WHERE book_id = 1;
-- (앱이 화면에 「재고 5권 가운데 1권을 2번 매장 몫으로 옮길까요?」를 띄우고 직원의 확인을 기다린다 — 보통 몇 초, 길면 몇 분)
-- 확인되면 읽어 둔 값에서 1을 뺀 값을 쓴다
UPDATE books SET stock = 4 WHERE book_id = 1;
UPDATE books SET stock = stock + 1 WHERE book_id = 2;
INSERT INTO peer.transfer_log (request_id, book_id, moved) VALUES ('T-1001', 1, -1), ('T-1001', 2, 1);
COMMIT;

-- [3] 반대 방향(2번 책 → 1번 책) 이동은 앱의 다른 화면이 처리하며, 2번 책부터 고친다
BEGIN;
UPDATE books SET stock = stock - 1 WHERE book_id = 2;
UPDATE books SET stock = stock + 1 WHERE book_id = 1;
INSERT INTO peer.transfer_log (request_id, book_id, moved) VALUES ('T-1002', 2, -1), ('T-1002', 1, 1);
COMMIT;
