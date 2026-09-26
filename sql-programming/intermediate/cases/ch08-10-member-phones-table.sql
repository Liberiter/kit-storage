-- runner: reset
-- 8장 8.1 «practice» 1: 번호 붙은 칸(phone1~3)을 자식 표로 옮기고 번호 하나로 찾는다
CREATE TABLE antipatterns.member_phones (
    member_email text NOT NULL REFERENCES antipatterns.members (email),
    phone text NOT NULL,
    PRIMARY KEY (member_email, phone)
);

INSERT INTO antipatterns.member_phones (member_email, phone)
SELECT email, phone1
FROM antipatterns.members
WHERE phone1 IS NOT NULL
UNION ALL
SELECT email, phone2
FROM antipatterns.members
WHERE phone2 IS NOT NULL
UNION ALL
SELECT email, phone3
FROM antipatterns.members
WHERE phone3 IS NOT NULL;

SELECT count(*) AS 번호수 FROM antipatterns.member_phones;

SELECT member_email AS 회원이메일
FROM antipatterns.member_phones
WHERE phone = '010-3333-4445';
