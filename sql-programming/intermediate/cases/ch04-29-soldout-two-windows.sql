-- 4장 4.3 «따라 하기» 3단계: 창 둘을 한 질의에 나란히 둔다
SELECT
    category AS 분야,
    title AS 제목,
    price AS 가격,
    round(avg(price) OVER (PARTITION BY category)) AS "분야 평균가",
    round(avg(price) OVER ()) AS "전체 평균가"
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, price DESC, book_id;
