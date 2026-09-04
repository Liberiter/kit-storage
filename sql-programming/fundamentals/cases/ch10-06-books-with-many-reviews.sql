-- 10.1 따라 하기 4단계: 여러 행을 내놓는 서브쿼리를 IN의 오른쪽에 놓는다.
-- 10.1 개념의 서식 규칙 예제(R34)와 입력이 같다(그 자리는 출력을 싣지 않는다).
SELECT book_id AS 도서번호, title AS 제목
FROM books
WHERE book_id IN (
    SELECT book_id FROM reviews GROUP BY book_id HAVING count(*) >= 5
)
ORDER BY book_id;
