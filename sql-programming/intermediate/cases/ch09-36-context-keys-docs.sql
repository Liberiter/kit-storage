-- 9장 «연습하기» exercise 5 해설 (공식 문서만 보고 적용): jsonb_object_keys 로 context 의 키마다 조회 수
WITH context_keys AS (
    SELECT jsonb_object_keys(context) AS 키 FROM page_views
)
SELECT 키, count(*) AS 조회수
FROM context_keys
GROUP BY 키
ORDER BY 조회수 DESC, 키;
