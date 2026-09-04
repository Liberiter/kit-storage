-- 11.2 따라 하기 5단계 — 바꾸기 전에 같은 조건으로 걸리는 행을 세어 둔다
SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '에세이';
