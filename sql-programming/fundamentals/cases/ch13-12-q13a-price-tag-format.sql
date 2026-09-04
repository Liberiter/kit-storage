-- 13장 exit assessment 문항 13 (가) 해설: 문서에서 찾은 숫자 서식 패턴을 적용한다
SELECT
    book_id AS 도서번호,
    title AS 제목,
    to_char(price, 'FM999,999') || '원' AS 정가
FROM books
WHERE price >= 41000
ORDER BY price DESC, book_id;
