-- 9장 «연습하기» exercise 4 해설: 서울 날짜 8월 30일, 「여행」 태그 책 페이지의 기기별 조회 수
SELECT page_views.context ->> 'device' AS 기기, count(*) AS 조회수
FROM page_views
INNER JOIN book_meta ON page_views.book_id = book_meta.book_id
WHERE book_meta.tags @> ARRAY['여행']
    AND page_views.viewed_at >= '2026-08-30 00:00:00+09'
    AND page_views.viewed_at < '2026-08-31 00:00:00+09'
GROUP BY page_views.context ->> 'device'
ORDER BY 조회수 DESC;
