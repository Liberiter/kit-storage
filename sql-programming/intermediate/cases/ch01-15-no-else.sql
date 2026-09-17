-- 1장 1.2 «따라 하기» 3단계: ELSE 를 빼면 맞는 WHEN 이 없는 행은 널이 된다
SELECT
    book_id AS 도서번호,
    price AS 가격,
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
    END AS 가격대
FROM books
WHERE book_id IN (46, 94, 171, 20)
ORDER BY price;
