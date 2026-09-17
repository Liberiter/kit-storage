-- 9.1 practice 2 풀이: 소설 분야의 권수·최저가·최고가·평균가격
SELECT
    count(*) AS 권수,
    min(price) AS 최저가,
    max(price) AS 최고가,
    round(avg(price), 1) AS 평균가격
FROM books
WHERE category = '소설';
