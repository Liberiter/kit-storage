-- runner: reset
-- 12장 도전하기 problem 2 지문: 동료의 재고 보충 — 인덱스를 두고, 재고와 어제 조회 수를 본 뒤 읽은 재고에 10을 더한 값을 적는다
CREATE INDEX page_views_viewed_at_idx ON page_views (viewed_at);

BEGIN;
SELECT stock FROM books WHERE book_id = 12;

SELECT count(*) AS 어제조회수
FROM page_views
WHERE book_id = 12
    AND CAST(viewed_at AT TIME ZONE 'Asia/Seoul' AS date) = '2026-08-31';

UPDATE books SET stock = 13 WHERE book_id = 12;
COMMIT;
