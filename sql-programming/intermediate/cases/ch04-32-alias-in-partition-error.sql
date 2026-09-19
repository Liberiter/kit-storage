-- 4장 4.3 «흔한 실수»: 같은 질의에서 만든 별칭은 PARTITION BY 에 쓸 수 없다
SELECT
    category AS 분야,
    price AS 가격,
    round(avg(price) OVER (PARTITION BY 분야)) AS "분야 평균가"
FROM books
WHERE stock = 0;
