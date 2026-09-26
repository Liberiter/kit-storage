-- 9장 9.1 «따라 하기» 5단계: 서울 날짜 하루를 오프셋을 붙인 반열린 범위로 고른다 (3단계와 같은 1797)
SELECT count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-06-01 00:00:00+09'
    AND viewed_at < '2026-06-02 00:00:00+09';
