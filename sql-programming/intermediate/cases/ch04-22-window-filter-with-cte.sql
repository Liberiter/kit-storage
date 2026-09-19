-- 4장 4.2 «흔한 실수»: 창의 값으로 거르려면 이름을 붙여 바깥에서 거른다
WITH science_books AS (
    SELECT
        book_id,
        title AS 제목,
        price AS 가격,
        round(avg(price) OVER ()) AS 분야평균
    FROM books
    WHERE category = '과학'
)
SELECT 제목, 가격, 분야평균
FROM science_books
WHERE 가격 > 분야평균
ORDER BY 가격 DESC, book_id;
