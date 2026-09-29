-- 11장 «복습 exercise» 1 지문 (2장): 동료의 NOT IN — 서브쿼리에 널이 섞여 0행
SELECT customers.customer_id, customers.name
FROM customers
WHERE customers.customer_id NOT IN (
    SELECT page_views.customer_id
    FROM page_views
    WHERE page_views.viewed_at >= '2026-08-31 00:00:00+09'
        AND page_views.viewed_at < '2026-09-01 00:00:00+09'
);
