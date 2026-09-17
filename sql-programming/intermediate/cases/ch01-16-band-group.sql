-- 1장 1.2 «따라 하기» 4단계: CASE 식을 그룹 키로 쓴다
SELECT
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END AS 가격대,
    count(*) AS 권수
FROM books
GROUP BY
    CASE
        WHEN price < 10000 THEN '1만원 미만'
        WHEN price < 20000 THEN '1만원대'
        ELSE '2만원 이상'
    END
ORDER BY 권수 DESC;
