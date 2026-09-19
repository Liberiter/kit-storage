-- 3장 3.3 «문제 상황»: 상관 서브쿼리는 값 하나씩만 가져온다
SELECT
    b.category AS 분야,
    (
        SELECT t.title
        FROM books AS t
        WHERE t.category = b.category
        ORDER BY t.price DESC, t.book_id
        LIMIT 1
    ) AS "가장 비싼 책",
    max(b.price) AS 최고가
FROM books AS b
GROUP BY b.category
ORDER BY b.category;
