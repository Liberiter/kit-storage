-- problem 1 해설: 여행 분야 매대 라벨 (이어붙이기 + length)
SELECT
    title || ' / ' || author AS 라벨,
    length(title || ' / ' || author) AS 글자수
FROM books
WHERE category = '여행'
ORDER BY 글자수 DESC, book_id
LIMIT 5;
