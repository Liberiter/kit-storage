-- 3장 3.2 흔한 실수: 기호 없는 LIKE는 = 와 같게 동작한다 (0행)
SELECT title FROM books WHERE title LIKE '제주';
