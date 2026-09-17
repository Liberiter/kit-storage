-- 9.2 따라 하기 2단계: 그룹마다 집계를 여럿 낸다
SELECT
    category AS 분야,
    count(*) AS 권수,
    round(avg(price), 1) AS 평균가격,
    max(price) AS 최고가
FROM books
GROUP BY category
ORDER BY 평균가격 DESC;
