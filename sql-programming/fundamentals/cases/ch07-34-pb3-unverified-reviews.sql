-- problem 3 (b) 해설: orders와 조인하지 않고 books와만 조인해야 220건이 남는다
SELECT reviews.review_id, books.title, reviews.rating, reviews.review_date
FROM reviews
INNER JOIN books ON reviews.book_id = books.book_id
WHERE reviews.order_id IS NULL
ORDER BY reviews.review_id
LIMIT 5;
