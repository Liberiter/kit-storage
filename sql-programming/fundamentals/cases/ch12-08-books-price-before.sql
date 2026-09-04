-- 12.2 문제 상황 — 값을 올리기 전 책 전체의 가격대
SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가 FROM books;
