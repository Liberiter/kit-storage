-- runner: reset
-- 11.2 따라 하기 4단계 — 조건에 맞는 행이 없어도 오류가 아니다
UPDATE books SET stock = 20 WHERE title = '오늘의 정원 수업 노트';

SELECT count(*) AS 걸린책 FROM books WHERE title = '오늘의 정원 수업 노트';
