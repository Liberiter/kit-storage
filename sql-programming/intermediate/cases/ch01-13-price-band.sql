-- 1장 1.2 «따라 하기» 1단계: 값에 따라 갈리는 이름을 한 열로 만든다
SELECT
    title AS 제목,
    price AS 가격,
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대
FROM books
WHERE book_id <= 5
ORDER BY book_id;
