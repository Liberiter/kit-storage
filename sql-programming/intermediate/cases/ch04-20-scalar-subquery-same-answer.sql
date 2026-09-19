-- 4장 4.2 «왜 그럴까요»: 스칼라 서브쿼리로 같은 답을 낸다 (ch04-16 과 같은 출력)
SELECT
    title AS 제목,
    price AS 가격,
    (SELECT round(avg(price)) FROM books WHERE category = '과학')
        AS "분야 평균"
FROM books
WHERE category = '과학'
ORDER BY price DESC, book_id
LIMIT 5;
