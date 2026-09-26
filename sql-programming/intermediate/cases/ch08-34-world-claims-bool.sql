-- 8장 주장 케이스 (불리언) — 본문에 코드 블록으로 등장하지 않는다.
-- 값이 참·거짓이라 정수·글자 표와 타입이 섞이므로 따로 뒀다. 뒷받침하는 자리:
--   2024/03/15 는 날짜로 읽히고 24-04-02 는 읽히지 않는다 → «연습하기» exercise 1
--     «채점 포인트»의 「2024/03/15 는 서버가 알아보지만」과 「24-04-02 를 그대로 날짜로
--     바꾸려 하면 … 오류」
--   real 로 담긴 BK-004 가격은 18000.5 와 정확히 같고 BK-010 가격은 22000.1 과 다르다
--     → «연습하기» exercise 2 «채점 포인트»의 「18000.5 는 real 에 정확히 담기는 값이고,
--     22000.1 은 근삿값으로 담긴 값」
--   쉼표 뒤에 빈칸이 있는 목록에서는 쉼표로 감싼 LIKE 가 교양을 찾지 못한다 → 8.1
--     «따라 하기» 2단계 해설의 「'한국사, 교양' 처럼 … 적는 순간 이 질의는 그 상품을
--     조용히 놓칩니다」
--   real 로 맞춘 15999.99 로 견주면 BK-001 이 찾아진다 → 8.1 «왜 그럴까요» [참고]의
--     「CAST(15999.99 AS real) 처럼 … 만들면 BK-001 이 찾아집니다」
--   BK-001 의 화면 글자를 수로 읽으면 15999.99 → 8.1 «왜 그럴까요»의 「BK-001 은 화면의
--     15999.99 가 처음 적은 값과 같으니」 (처음 적은 값은 kit 의 적재 문장이 적은 15999.99)
SELECT '2024/03/15 를 날짜로 읽을 수 있는가' AS 주장,
       pg_input_is_valid('2024/03/15', 'date') AS 실측값
UNION ALL
SELECT '24-04-02 를 날짜로 읽을 수 있는가',
       pg_input_is_valid('24-04-02', 'date')
UNION ALL
SELECT 'BK-004 의 real 가격이 18000.5 와 정확히 같은가',
       CAST(price AS double precision) = CAST(18000.5 AS double precision)
FROM antipatterns.products WHERE code = 'BK-004'
UNION ALL
SELECT 'BK-010 의 real 가격이 22000.1 과 정확히 같은가',
       CAST(price AS double precision) = CAST(22000.1 AS double precision)
FROM antipatterns.products WHERE code = 'BK-010'
UNION ALL
SELECT '쉼표 뒤 빈칸이 있는 목록에서 교양을 찾는가',
       ',' || '한국사, 교양' || ',' LIKE '%,교양,%'
UNION ALL
SELECT 'real 로 맞춘 15999.99 로 BK-001 을 찾는가',
       price = CAST(15999.99 AS real)
FROM antipatterns.products WHERE code = 'BK-001'
UNION ALL
SELECT 'BK-001 화면 글자를 수로 읽으면 15999.99 인가',
       CAST(CAST(price AS text) AS numeric) = 15999.99
FROM antipatterns.products WHERE code = 'BK-001';
