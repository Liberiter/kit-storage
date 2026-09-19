-- 4장 4.3 «practice» 1: 가격대별 권수가 그 분야 안에서 차지하는 비중
WITH band_count AS (
    SELECT
        category AS 분야,
        CASE
            WHEN price < 15000 THEN '1만5천원 미만'
            WHEN price < 35000 THEN '중간'
            ELSE '3만5천원 이상'
        END AS 가격대,
        count(*) AS 권수
    FROM books
    WHERE category IN ('에세이', '요리')
    GROUP BY
        category,
        CASE
            WHEN price < 15000 THEN '1만5천원 미만'
            WHEN price < 35000 THEN '중간'
            ELSE '3만5천원 이상'
        END
)
SELECT
    분야,
    가격대,
    권수,
    round(100.0 * 권수 / sum(권수) OVER (PARTITION BY 분야), 1) AS "비중(%)"
FROM band_count
ORDER BY 분야, 권수 DESC, 가격대;
