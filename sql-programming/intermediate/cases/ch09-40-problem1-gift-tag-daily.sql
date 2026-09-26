-- 9장 «도전하기» problem 1 해설: 8월 마지막 주(서울 날짜) 「선물추천」 태그 책 페이지의 날짜별 조회 수와 광고 유입
WITH gift_views AS (
    SELECT
        CAST(page_views.viewed_at AT TIME ZONE 'Asia/Seoul' AS date) AS 날짜,
        page_views.context ->> 'referrer' AS 유입경로
    FROM page_views
    INNER JOIN book_meta ON page_views.book_id = book_meta.book_id
    WHERE book_meta.tags @> ARRAY['선물추천']
        AND page_views.viewed_at >= '2026-08-24 00:00:00+09'
        AND page_views.viewed_at < '2026-08-31 00:00:00+09'
)
SELECT
    날짜,
    count(*) AS 조회수,
    count(*) FILTER (WHERE 유입경로 = 'ad') AS 광고유입
FROM gift_views
GROUP BY 날짜
ORDER BY 날짜;
