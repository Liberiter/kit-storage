-- 10.1 따라 하기 3단계: 서브쿼리를 선택 목록에 놓아 전체 평균을 함께 보인다
SELECT
    title AS 제목,
    price AS 가격,
    (SELECT round(avg(price)) FROM books) AS 전체평균
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
