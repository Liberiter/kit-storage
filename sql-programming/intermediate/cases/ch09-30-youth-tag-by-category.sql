-- 9장 9.3 «practice» 1: 「청소년추천」 태그가 붙은 책을 분류별로 센다
SELECT books.category AS 분류, count(*) AS 책수
FROM book_meta
INNER JOIN books ON book_meta.book_id = books.book_id
WHERE book_meta.tags @> ARRAY['청소년추천']
GROUP BY books.category
ORDER BY 책수 DESC, 분류;
