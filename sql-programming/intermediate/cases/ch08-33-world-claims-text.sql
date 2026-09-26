-- 8장 주장 케이스 (글자) — 본문에 코드 블록으로 등장하지 않는다.
-- 값이 글자라 정수 표와 타입이 섞이므로 따로 뒀다. 뒷받침하는 자리:
--   BK-008 로 적힌 두 상품의 이름 → 8.1 «따라 하기» 1단계 해설의 「두 줄은 「빛나는 제주
--     여행 사전」과 그 개정판」
--   hayun.choi@oldshop.kr 회원의 이름 → 8.1 «흔한 실수»의 「최하윤 님이 이메일을 바꿨다」
--   members 의 기본키 정의 → 8.1 «개념» 표의 「members 의 기본키가 이메일」, 8.1 «흔한 실수»
--   order_items 의 기본키 정의 → 8.2 «practice» 2 해설의 「기본키가 (order_id, book_id)」
--   product_attributes.attr_value 의 타입 → 8.1 «따라 하기» 4단계 해설의 「무엇이든 받는
--     text 일 수밖에 없습니다」
--   24-04-02 를 날짜로 읽을 때의 오류 문구 → «연습하기» exercise 1 «채점 포인트»의
--     「date/time field value out of range 오류」
--   글자인 created_on 의 max → «연습하기» exercise 1 해설의 「max(created_on)은
--     24-04-02를 냅니다」 (해설 블록은 그 질의를 싣지 않는다)
SELECT 'BK-008 로 적힌 두 상품의 이름' AS 주장,
       string_agg(name, ' / ' ORDER BY name) AS 실측값
FROM antipatterns.products WHERE code = 'BK-008'
UNION ALL
SELECT 'hayun.choi@oldshop.kr 회원의 이름', name
FROM antipatterns.members WHERE email = 'hayun.choi@oldshop.kr'
UNION ALL
SELECT 'members 의 기본키 정의', pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'antipatterns.members'::regclass AND contype = 'p'
UNION ALL
SELECT 'order_items 의 기본키 정의', pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'order_items'::regclass AND contype = 'p'
UNION ALL
SELECT 'product_attributes.attr_value 의 타입', data_type
FROM information_schema.columns
WHERE table_schema = 'antipatterns' AND table_name = 'product_attributes'
    AND column_name = 'attr_value'
UNION ALL
SELECT '24-04-02 를 날짜로 읽을 때의 오류', message
FROM pg_input_error_info('24-04-02', 'date')
UNION ALL
SELECT '글자인 created_on 의 max', max(created_on)
FROM antipatterns.products;
