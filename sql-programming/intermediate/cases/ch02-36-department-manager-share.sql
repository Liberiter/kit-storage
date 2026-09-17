-- 2장 «복습 exercise» 1 해설 (1장 — 조건 집계)
SELECT
    s.department AS 부서,
    count(*) AS 인원,
    count(*) FILTER (
        WHERE EXISTS (SELECT 1 FROM staff AS x WHERE x.manager_id = s.staff_id)
    ) AS "부하가 있는 사람"
FROM staff AS s
GROUP BY s.department
ORDER BY 인원 DESC, 부서;
