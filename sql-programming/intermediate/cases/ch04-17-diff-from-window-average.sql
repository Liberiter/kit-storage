-- 4장 4.2 «따라 하기» 2단계: 평균과의 차이를 계산한다
SELECT
    title AS 제목,
    price AS 가격,
    round(avg(price) OVER ()) AS "분야 평균",
    price - round(avg(price) OVER ()) AS 차이
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
