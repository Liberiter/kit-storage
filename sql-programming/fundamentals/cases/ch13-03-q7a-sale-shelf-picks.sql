-- 13장 exit assessment 문항 7 (가) 해설: 균일가 매대에 올릴 여행·요리 책 6권
SELECT
    book_id AS 도서번호,
    title AS 제목,
    category AS 분야,
    price AS 정가,
    stock AS 재고
FROM books
WHERE category IN ('여행', '요리') AND price BETWEEN 12000 AND 20000
ORDER BY 재고 DESC, 도서번호
LIMIT 6;
