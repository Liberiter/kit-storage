-- 6.1 따라 하기 3단계: 글자 타입의 이어붙이기
SELECT title || ' / ' || author AS "제목과 지은이"
FROM books
ORDER BY book_id
LIMIT 5;
