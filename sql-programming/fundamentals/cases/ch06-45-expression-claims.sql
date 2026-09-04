-- 6장 본문이 출력 블록 없이 참이라고 말한 식들을 실측값으로 고정한다 (D-017).
-- 각 행이 "식 → 실측 결과" 쌍이며, value 열이 한 종류여야 하므로 글자로 옮겨 담는다.
--  · 6.2 흔한 실수: CAST('42' AS integer)는 오류 없이 42가 된다
--  · 6.2 왜 그럴까요: 9500 / 1000.0은 CAST(9500 AS numeric) / 1000과 같은 값이다
--  · 6.2 practice 1 해설: page_count / 100은 408을 4로 만든다
--  · 6.3 개념: 5장의 COALESCE도 함수와 같은 모양의 호출이다
--  · 복습 exercise 채점 포인트: CAST로 numeric을 만들면 42000은
--    4.2000000000000000, 41500은 4.1500000000000000으로 서로 달라진다
--  · problem 2 해설: 형변환이 늦으면 124500이 124.5가 아니라 124.0이 된다
SELECT 'CAST(''42'' AS integer)' AS claim,
       CAST(CAST('42' AS integer) AS text) AS value
UNION ALL
SELECT '9500 / 1000.0', CAST(9500 / 1000.0 AS text)
UNION ALL
SELECT 'CAST(9500 AS numeric) / 1000',
       CAST(CAST(9500 AS numeric) / 1000 AS text)
UNION ALL
SELECT '위 두 식이 같은 값인가',
       CAST((9500 / 1000.0 = CAST(9500 AS numeric) / 1000) AS text)
UNION ALL
SELECT '408 / 100', CAST(408 / 100 AS text)
UNION ALL
SELECT 'round(124500 / 1000, 1)', CAST(round(124500 / 1000, 1) AS text)
UNION ALL
SELECT 'round(CAST(124500 AS numeric) / 1000, 1)',
       CAST(round(CAST(124500 AS numeric) / 1000, 1) AS text)
UNION ALL
SELECT 'CAST(42000 AS numeric) / 10000',
       CAST(CAST(42000 AS numeric) / 10000 AS text)
UNION ALL
SELECT 'CAST(41500 AS numeric) / 10000',
       CAST(CAST(41500 AS numeric) / 10000 AS text)
UNION ALL
SELECT 'COALESCE(NULL, ''(내용 없음)'')',
       COALESCE(NULL, '(내용 없음)');
