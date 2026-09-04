-- 2장 2.1 개념의 'books 테이블의 열' 표를 world에서 그대로 재구성한다.
-- 표에 적힌 열 이름·순서·타입이 실제 스키마와 일치하는지 대조하는 용도다.
SELECT ordinal_position AS "순서", column_name AS "열 이름",
       data_type AS "타입", is_nullable AS "NULL 허용"
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'books'
ORDER BY ordinal_position;
