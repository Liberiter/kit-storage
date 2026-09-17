-- 1장 1.2 «따라 하기» 2단계: 경계값에서 어느 WHEN 이 맞는지 확인한다
SELECT
    book_id AS 도서번호,
    price AS 가격,
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대
FROM books
WHERE book_id IN (46, 94, 171, 20)
ORDER BY price;
