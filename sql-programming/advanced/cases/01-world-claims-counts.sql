-- kit smoke: 주장 케이스 — README 「World」 표의 행 수 (대규모 테이블과 앞 코스에서 이어 온 핵심 테이블)
SELECT claim, value FROM (
SELECT 'stores' AS claim, count(*) AS value FROM stores
UNION ALL SELECT 'accounts', count(*) FROM accounts
UNION ALL SELECT 'accounts linked to customers', count(*) FROM accounts WHERE customer_id IS NOT NULL
UNION ALL SELECT 'sales', count(*) FROM sales
UNION ALL SELECT 'sales disputed', count(*) FROM sales WHERE status = 'disputed'
UNION ALL SELECT 'shipments_sorted', count(*) FROM shipments_sorted
UNION ALL SELECT 'shipments_random', count(*) FROM shipments_random
UNION ALL SELECT 'book_contents', count(*) FROM book_contents
UNION ALL SELECT 'discussion_posts', count(*) FROM discussion_posts
UNION ALL SELECT 'duty_roster', count(*) FROM duty_roster
UNION ALL SELECT 'books', count(*) FROM books
UNION ALL SELECT 'customers', count(*) FROM customers
UNION ALL SELECT 'page_views', count(*) FROM page_views
UNION ALL SELECT 'theory.talk_signups', count(*) FROM theory.talk_signups
UNION ALL SELECT 'theory.club_mentors', count(*) FROM theory.club_mentors
UNION ALL SELECT 'theory.order_book_lines', count(*) FROM theory.order_book_lines
) t
ORDER BY claim;
