-- 2장 «도전하기» problem 1 해설 — 부서별 조직 요약
SELECT
    s.department AS 부서,
    count(*) AS 인원,
    count(*) FILTER (
        WHERE EXISTS (SELECT 1 FROM staff AS x WHERE x.manager_id = s.staff_id)
    ) AS "부하가 있는 사람",
    count(*) FILTER (
        WHERE EXISTS (
            SELECT 1
            FROM staff AS m
            WHERE m.staff_id = s.manager_id
                AND m.department <> s.department
        )
    ) AS "상사가 다른 부서인 사람"
FROM staff AS s
GROUP BY s.department
ORDER BY 인원 DESC, 부서;
