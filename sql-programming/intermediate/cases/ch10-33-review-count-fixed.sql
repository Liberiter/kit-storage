-- runner: reset
-- 10장 «연습하기» exercise 3 해설: 매개변수 이름을 열과 겹치지 않게 고친 함수
CREATE FUNCTION book_review_count(target_book integer)
RETURNS bigint
LANGUAGE sql
AS $$
SELECT count(*) AS 리뷰수 FROM reviews WHERE reviews.book_id = target_book;
$$;

SELECT book_id, book_review_count(book_id) AS 리뷰수
FROM books
WHERE book_id <= 3
ORDER BY book_id;
