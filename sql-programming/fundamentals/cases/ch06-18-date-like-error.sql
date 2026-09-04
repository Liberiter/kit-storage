-- 6.2 따라 하기 4단계: 날짜 열에 LIKE를 걸면 연산자가 없다 (오류 기대)
SELECT title, published_date FROM books WHERE published_date LIKE '2025%';
