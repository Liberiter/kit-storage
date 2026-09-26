-- 9장 9.1 «흔한 실수» 2: 오프셋 없이 적은 범위는 세션 시간대(UTC)로 읽힌다 — 서울 하루가 아니라 UTC 하루
SELECT count(*) AS 조회수
FROM page_views
WHERE viewed_at >= '2026-06-01' AND viewed_at < '2026-06-02';
