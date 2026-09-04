-- 4장 4.2 왜 그럴까요: 유일한 열(book_id)을 마지막 정렬 키로 두어 순서를 고정한 상위 5종
SELECT title, price FROM books ORDER BY price DESC, book_id LIMIT 5;
