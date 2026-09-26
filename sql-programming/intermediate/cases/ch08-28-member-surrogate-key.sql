-- runner: reset
-- 8장 «복습 exercise» 2 해설 (6장 — 자연 키와 대리 키): 번호를 키로, 이메일은 겹치지 않는 값으로
CREATE TABLE antipatterns.member_accounts (
    member_id integer PRIMARY KEY,
    email text NOT NULL UNIQUE,
    name text NOT NULL
);

INSERT INTO antipatterns.member_accounts (member_id, email, name)
SELECT row_number() OVER (ORDER BY email), email, name
FROM antipatterns.members;

UPDATE antipatterns.member_accounts
SET email = 'hayun.choi@newmail.kr'
WHERE email = 'hayun.choi@oldshop.kr'
RETURNING member_id, OLD.email AS 예전이메일, NEW.email AS 새이메일;
