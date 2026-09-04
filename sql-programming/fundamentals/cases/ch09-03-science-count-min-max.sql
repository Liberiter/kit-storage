-- 9.1 따라 하기 2단계: 과학 분야의 권수·최저가·최고가를 한 줄로
SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '과학';
