-- 13장 exit assessment 문항 7 (나) 해설: 같은 여섯 권을 집합 연산으로 구한다
SELECT
    book_id AS 도서번호,
    title AS 제목,
    category AS 분야,
    price AS 정가,
    stock AS 재고
FROM books
WHERE category = '여행' AND price BETWEEN 12000 AND 20000
UNION
SELECT
    book_id,
    title,
    category,
    price,
    stock
FROM books
WHERE category = '요리' AND price BETWEEN 12000 AND 20000
ORDER BY 재고 DESC, 도서번호
LIMIT 6;
