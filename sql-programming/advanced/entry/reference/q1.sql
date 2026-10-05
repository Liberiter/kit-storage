-- 입장 점검 문항 1 참조 해답
WITH leaf_top AS (
  -- 책의 분류가 '전체' 바로 아래면 그 자신, 한 단계 더 아래면 그 위 분류
  SELECT c.name AS leaf,
         CASE WHEN p.parent_id IS NULL THEN c.name ELSE p.name END AS top_category
    FROM categories c
    JOIN categories p ON p.category_id = c.parent_id
),
monthly AS (
  SELECT to_char(o.order_date, 'YYYY-MM') AS month, lt.top_category,
         sum(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN books b ON b.book_id = oi.book_id
    JOIN leaf_top lt ON lt.leaf = b.category
   WHERE o.order_date >= DATE '2026-01-01' AND o.order_date < DATE '2026-07-01'
     AND o.status <> '취소'
   GROUP BY 1, 2
)
SELECT month, top_category, revenue,
       round(100.0 * revenue / sum(revenue) OVER (PARTITION BY month), 1) AS share_pct,
       rank() OVER (PARTITION BY month ORDER BY revenue DESC) AS rank_in_month
  FROM monthly
 ORDER BY month, rank_in_month, top_category;
