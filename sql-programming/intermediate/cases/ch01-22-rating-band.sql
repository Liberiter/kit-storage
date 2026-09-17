-- 1장 1.2 «practice» 2: 별점을 세 구간으로 갈라 센다
SELECT
    CASE
        WHEN rating >= 4 THEN '높음'
        WHEN rating = 3 THEN '보통'
        ELSE '낮음'
    END AS 별점구간,
    count(*) AS 리뷰수
FROM reviews
GROUP BY
    CASE
        WHEN rating >= 4 THEN '높음'
        WHEN rating = 3 THEN '보통'
        ELSE '낮음'
    END
ORDER BY 리뷰수 DESC;
