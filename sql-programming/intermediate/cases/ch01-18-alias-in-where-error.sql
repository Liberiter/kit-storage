-- 1장 1.2 «왜 그럴까요»: 선택 목록의 별칭은 WHERE 에서 쓸 수 없다
SELECT
    title AS 제목,
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대
FROM books
WHERE 가격대 = '1만원 미만'
ORDER BY book_id;
