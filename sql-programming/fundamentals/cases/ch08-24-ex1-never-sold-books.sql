-- exercise 1 해설: 한 번도 주문에 담기지 않은 책 (LIMIT을 떼면 18행)
SELECT books.book_id, books.title, books.category
FROM books
LEFT JOIN order_items ON books.book_id = order_items.book_id
WHERE order_items.order_id IS NULL
ORDER BY books.book_id
LIMIT 5;
