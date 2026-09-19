-- 4장 4.3 «문제 상황»: 품절 도서 목록에 OVER () 로 붙인 평균가는 하나뿐이다
SELECT
    category AS 분야,
    title AS 제목,
    price AS 가격,
    round(avg(price) OVER ()) AS 평균가
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, price DESC, book_id;
