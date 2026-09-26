-- 9장 9.3 «따라 하기» 2단계: 원소로 찾으면 「교양」만, 글자로 찾으면 「교양과학」까지
SELECT
    count(*) FILTER (WHERE tags @> ARRAY['교양']) AS 포함으로,
    count(*) FILTER (WHERE '교양' = ANY (tags)) AS 하나라도같으면,
    count(*) FILTER (WHERE CAST(tags AS text) LIKE '%교양%') AS 글자로찾기
FROM book_meta;
