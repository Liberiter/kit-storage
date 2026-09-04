-- problem 3 (c): 두 곳을 모두 고친 질의
SELECT
    title,
    round(CAST(price AS numeric) / 10000, 1) AS 만원,
    length(CAST(price AS text)) AS 자릿수
FROM books
ORDER BY book_id
LIMIT 5;
