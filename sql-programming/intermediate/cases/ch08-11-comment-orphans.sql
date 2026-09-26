-- 8장 8.1 «practice» 2: 다형 연결의 고아 행 — 대상 종류마다 질의를 따로 써서 이어야 한다
SELECT comment_id AS 댓글번호, target_type AS 대상종류, target_id AS 대상
FROM antipatterns.comments
WHERE target_type = 'product'
    AND NOT EXISTS (
        SELECT 1
        FROM antipatterns.products
        WHERE antipatterns.products.code = antipatterns.comments.target_id
    )
UNION ALL
SELECT comment_id, target_type, target_id
FROM antipatterns.comments
WHERE target_type = 'member'
    AND NOT EXISTS (
        SELECT 1
        FROM antipatterns.members
        WHERE antipatterns.members.email = antipatterns.comments.target_id
    )
ORDER BY 댓글번호;
