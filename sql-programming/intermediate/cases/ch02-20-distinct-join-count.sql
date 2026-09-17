-- 2장 2.2 «왜 그럴까요» — 조인으로 같은 답을 내려면 중복을 지워야 한다
SELECT count(DISTINCT books.book_id) AS 권수
FROM books
INNER JOIN reviews ON books.book_id = reviews.book_id;
