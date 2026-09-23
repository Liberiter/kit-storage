-- 7장 주장 케이스 (글자) — 본문에 코드 블록으로 등장하지 않는다.
-- 값이 글자라 정수 표(ch07-48)와 타입이 섞이므로 따로 뒀다 (D-038).
-- 뒷받침하는 자리:
--   orders.status 의 CHECK 정의 → «도전하기» problem 3 «채점 포인트»의 「네 값만
--     받도록 검사 제약으로 못 박혀 있습니다」. 본문은 이 제약을 출력 블록으로 싣지
--     않으므로 그 문면을 여기서 고정한다 — 값 안에 네 값이 그대로 들어 있어 본문
--     문장과 바로 대조된다. psql 이 찍는 형태는 schema.sql 이 적은 `IN` 이 아니라
--     서버가 정규화한 `= ANY (ARRAY[...])` 다.
--   orders_check 의 정의 → «연습하기» exercise 2 지문의 「등가」 서술과 «채점
--     포인트»의 「반대쪽도 막힌다」. 실린 오류 메시지는 제약 이름만 증명하고 내용은
--     증명하지 않으므로 여기서 고정한다.
--   orders_check1 의 정의 → 같은 exercise 2 «채점 포인트»의 「나머지 하나는
--     「발송일이 주문일보다 앞설 수 없다」이며 이름이 orders_check1 입니다」.
--   1번 책과 2번 책의 ISBN → 7.1 «흔한 실수»의 「1번 책의 ISBN을 2번 책에
--     붙이려 했더니」. 실린 오류의 DETAIL 은 그 값이 어딘가에 이미 있다는 것만
--     증명하고 그것이 1번 책의 것이라는 것은 증명하지 않는다.
SELECT 'orders.status 의 CHECK 정의' AS 주장,
       pg_get_constraintdef(oid) AS 실측값
FROM pg_constraint
WHERE conname = 'orders_status_check'
UNION ALL
SELECT 'orders_check 의 정의', pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conname = 'orders_check'
UNION ALL
SELECT 'orders_check1 의 정의', pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conname = 'orders_check1'
UNION ALL
SELECT '1번 책의 ISBN', isbn13 FROM book_meta WHERE book_id = 1
UNION ALL
SELECT '2번 책의 ISBN', isbn13 FROM book_meta WHERE book_id = 2;
