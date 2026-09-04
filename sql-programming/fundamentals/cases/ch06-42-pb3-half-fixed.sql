-- problem 3 (b): 오류만 고친 질의 — 만원 열이 조용히 틀린 채로 남는다
SELECT
    title,
    round(price / 10000, 1) AS 만원,
    length(CAST(price AS text)) AS 자릿수
FROM books
ORDER BY book_id
LIMIT 5;
