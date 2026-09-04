-- 6.3 왜 그럴까요: round의 둘째 인자가 소수점 아래 자리 수를 정한다
SELECT
    round(CAST(29500 AS numeric) / 1000) AS "자리 수 없이",
    round(CAST(29500 AS numeric) / 1000, 1) AS "한 자리",
    round(CAST(29500 AS numeric) / 1000, 3) AS "세 자리";
