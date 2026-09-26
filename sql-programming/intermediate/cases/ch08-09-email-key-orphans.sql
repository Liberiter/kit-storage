-- runner: reset
-- 8장 8.1 «흔한 실수»: 바뀌는 값(이메일)을 키로 쓰면, 키를 고친 순간 그것을 가리키던 댓글이 고아가 된다
UPDATE antipatterns.members
SET email = 'hayun.choi@newmail.kr'
WHERE email = 'hayun.choi@oldshop.kr';

SELECT comment_id AS 댓글번호, target_id AS 가리키는대상, body AS 내용
FROM antipatterns.comments
WHERE target_type = 'member'
    AND NOT EXISTS (
        SELECT 1
        FROM antipatterns.members
        WHERE antipatterns.members.email = antipatterns.comments.target_id
    )
ORDER BY comment_id;
