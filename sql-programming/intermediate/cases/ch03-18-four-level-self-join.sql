-- 3장 3.2 «왜 그럴까요»: 조인 셋은 정확히 4단계인 사람만 낸다
SELECT
    s1.name AS "1단계",
    s2.name AS "2단계",
    s3.name AS "3단계",
    s4.name AS "4단계"
FROM staff AS s1
INNER JOIN staff AS s2 ON s2.manager_id = s1.staff_id
INNER JOIN staff AS s3 ON s3.manager_id = s2.staff_id
INNER JOIN staff AS s4 ON s4.manager_id = s3.staff_id
WHERE s1.manager_id IS NULL
ORDER BY s4.staff_id;
