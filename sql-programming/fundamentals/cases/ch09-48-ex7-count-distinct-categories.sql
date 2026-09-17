-- 복습 exercise (2장) (b) 해설: 같은 질문의 개수를 count(DISTINCT 열)로 센다
SELECT count(DISTINCT category) AS 분야수, count(DISTINCT author) AS 저자수
FROM books;
