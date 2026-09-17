-- 1장 1.2 «문제 상황»: 가격대마다 따로 세면 표가 하나로 모이지 않는다
SELECT count(*) AS 권수 FROM books WHERE price < 10000;
SELECT count(*) AS 권수 FROM books WHERE price BETWEEN 10000 AND 19999;
SELECT count(*) AS 권수 FROM books WHERE price >= 20000;
