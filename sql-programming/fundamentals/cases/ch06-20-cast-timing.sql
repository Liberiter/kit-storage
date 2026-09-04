-- 6.2 왜 그럴까요: 형변환을 언제 하느냐가 결과를 가른다
SELECT
    9500 / 1000 AS "둘 다 정수",
    9500 / CAST(1000 AS numeric) AS "한쪽만 numeric",
    CAST(9500 / 1000 AS numeric) AS "나눈 뒤 형변환";
