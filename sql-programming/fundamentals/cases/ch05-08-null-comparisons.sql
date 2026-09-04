-- 5.1 왜 그럴까요 — NULL이 낀 비교의 결과 자체를 본다
SELECT
    NULL = NULL AS "NULL = NULL",
    1 = NULL AS "1 = NULL",
    NULL IS NULL AS "NULL IS NULL";
