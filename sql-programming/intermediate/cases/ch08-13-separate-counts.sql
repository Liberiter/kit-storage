-- 8장 8.2 «따라 하기» 1단계: 두 질문을 따로 세어 문제 상황의 표와 맞춰 본다
SELECT book_id AS 도서번호, sum(quantity) AS 판매권수
FROM order_items
WHERE book_id <= 6
GROUP BY book_id
ORDER BY book_id;

SELECT
    book_id AS 도서번호,
    count(*) AS 리뷰수,
    round(avg(rating), 2) AS 평균별점
FROM reviews
WHERE book_id <= 6
GROUP BY book_id
ORDER BY book_id;
