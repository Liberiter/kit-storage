-- runner: reset
-- 11.3 따라 하기 3단계 — 조건에 맞는 행이 없어도 오류가 아니다
DELETE FROM books WHERE title = '없는 책';

SELECT count(*) AS 권수 FROM books;
