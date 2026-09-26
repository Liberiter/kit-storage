-- 8장 «복습 exercise» 1 해설 (1장 — CASE·조건 집계): 뜻이 같은 상태 표기를 모아 한 줄에 센다
WITH normalized AS (
    SELECT
        CASE
            WHEN status IN ('active', 'Active', 'ACTIVE', '활성') THEN '활성'
            WHEN status = 'inactive' THEN '비활성'
            WHEN status = 'soldout' THEN '품절'
            ELSE '확인 필요'
        END AS 상태
    FROM antipatterns.products
)
SELECT
    count(*) FILTER (WHERE 상태 = '활성') AS 활성,
    count(*) FILTER (WHERE 상태 = '비활성') AS 비활성,
    count(*) FILTER (WHERE 상태 = '품절') AS 품절,
    count(*) FILTER (WHERE 상태 = '확인 필요') AS 확인필요
FROM normalized;
