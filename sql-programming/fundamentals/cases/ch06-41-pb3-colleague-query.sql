-- problem 3 (a): 동료가 쓴 질의 — length에 숫자 열을 넘겨 오류가 난다 (오류 기대)
SELECT title, round(price / 10000, 1) AS 만원, length(price) AS 자릿수
FROM books
ORDER BY book_id
LIMIT 5;
