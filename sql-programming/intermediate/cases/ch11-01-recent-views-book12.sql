-- 11장 11.1 «문제 상황»: 12번 책의 최근 조회 다섯 건 — 결과만으로는 어떻게 찾았는지 보이지 않는다
SELECT view_id, viewed_at, customer_id
FROM page_views
WHERE book_id = 12
ORDER BY viewed_at DESC
LIMIT 5;
