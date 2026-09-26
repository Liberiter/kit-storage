-- 9장 9.2 «문제 상황»: context 칸에 담긴 것 (광고 유입인 11번에만 utm 이 있다)
SELECT view_id, context
FROM page_views
WHERE view_id IN (1, 11)
ORDER BY view_id;
