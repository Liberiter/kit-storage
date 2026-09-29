-- runner: reset
-- 10장 «연습하기» exercise 3 지문: 책마다 리뷰 수를 세려던 함수가 모두 520을 낸다
CREATE FUNCTION book_review_count(book_id integer)
RETURNS bigint
LANGUAGE sql
AS $$
SELECT count(*) AS 리뷰수 FROM reviews WHERE reviews.book_id = book_id;
$$;

SELECT book_id, book_review_count(book_id) AS 리뷰수
FROM books
WHERE book_id <= 3
ORDER BY book_id;
