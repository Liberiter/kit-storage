-- 복습 exercise 해설 (4·7장): 별점 높은 순 6번째부터 다섯 건 (LIMIT·OFFSET + 내부 조인)
SELECT reviews.review_id, books.title, reviews.rating
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
ORDER BY reviews.rating DESC, reviews.review_id
LIMIT 5 OFFSET 5;
