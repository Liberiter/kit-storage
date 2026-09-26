-- runner: reset
-- 8장 «도전하기» problem 1 해설: 다형 연결을 대상마다 외래키가 걸린 열로 나누고, 둘 중 하나만 차도록 CHECK 를 건다
UPDATE antipatterns.products
SET code = 'BK-016'
WHERE name = '빛나는 제주 여행 사전 (개정)';

ALTER TABLE antipatterns.products
ADD CONSTRAINT products_code_pkey PRIMARY KEY (code);

CREATE TABLE antipatterns.comments_linked (
    comment_id integer PRIMARY KEY,
    product_code text REFERENCES antipatterns.products (code),
    member_email text REFERENCES antipatterns.members (email),
    author_email text NOT NULL REFERENCES antipatterns.members (email),
    body text NOT NULL,
    CHECK ((product_code IS NULL) <> (member_email IS NULL))
);

INSERT INTO antipatterns.comments_linked (
    comment_id, product_code, member_email, author_email, body
)
SELECT comment_id, target_id, NULL, author_email, body
FROM antipatterns.comments
WHERE target_type = 'product'
    AND EXISTS (
        SELECT 1
        FROM antipatterns.products
        WHERE antipatterns.products.code = antipatterns.comments.target_id
    )
UNION ALL
SELECT comment_id, NULL, target_id, author_email, body
FROM antipatterns.comments
WHERE target_type = 'member'
    AND EXISTS (
        SELECT 1
        FROM antipatterns.members
        WHERE antipatterns.members.email = antipatterns.comments.target_id
    );

SELECT
    count(*) AS 옮긴댓글,
    count(product_code) AS 상품댓글,
    count(member_email) AS 회원댓글
FROM antipatterns.comments_linked;

INSERT INTO antipatterns.comments_linked (
    comment_id, product_code, member_email, author_email, body
)
VALUES (4, 'BK-099', NULL, 'sua.cho@oldshop.kr', '이 책은 언제 들어오나요');
