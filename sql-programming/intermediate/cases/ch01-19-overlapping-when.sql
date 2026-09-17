-- 1장 1.2 «흔한 실수»: 겹치는 조건은 앞의 WHEN 이 먼저 가져간다
SELECT
    book_id AS 도서번호,
    price AS 가격,
    CASE
        WHEN price >= 10000 THEN '1만원 이상'
        WHEN price >= 30000 THEN '3만원 이상'
        ELSE '1만원 미만'
    END AS 가격대
FROM books
WHERE book_id IN (46, 94, 4)
ORDER BY price;
