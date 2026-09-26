-- 8장 8.2 «흔한 실수»: 널이 섞인 이어붙이기는 통째로 널이 된다
SELECT name AS 이름, phone1 || ' / ' || phone2 AS 연락처
FROM antipatterns.members
ORDER BY email;

SELECT name AS 이름, phone1 || COALESCE(' / ' || phone2, '') AS 연락처
FROM antipatterns.members
ORDER BY email;
