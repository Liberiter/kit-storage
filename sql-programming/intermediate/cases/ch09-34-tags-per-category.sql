-- 9장 «연습하기» exercise 3 해설: 분류마다 책 한 권의 평균 태그 수와 태그가 하나뿐인 책 수
SELECT
    books.category AS 분류,
    round(avg(cardinality(book_meta.tags)), 2) AS 평균태그수,
    count(*) FILTER (WHERE cardinality(book_meta.tags) = 1) AS 태그하나뿐
FROM book_meta
INNER JOIN books ON book_meta.book_id = books.book_id
GROUP BY books.category
ORDER BY 분류;
