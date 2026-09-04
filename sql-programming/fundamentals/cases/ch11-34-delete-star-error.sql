-- 11.3 흔한 실수 — DELETE와 FROM 사이에는 아무것도 적지 않는다 (오류 기대)
DELETE * FROM books WHERE title = '없는 책';
