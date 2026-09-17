-- 2장 2.2 «따라 하기» 4단계 — 서브쿼리가 내놓는 목록에 널이 섞여 있다
SELECT count(*) AS 전체, count(manager_id) AS "상사번호가 있는 행" FROM staff;
