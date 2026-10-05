-- 입장 점검 문항 3 참조 해답 — 두 집계를 따로 낸 뒤 책에 붙인다 (조인이 행을 곱하지 않게)
SELECT b.book_id, b.title,
       coalesce(r.review_count, 0) AS review_count,
       coalesce(o.ordered_qty, 0) AS ordered_qty
  FROM books b
  LEFT JOIN (SELECT book_id, count(*) AS review_count FROM reviews GROUP BY book_id) r ON r.book_id = b.book_id
  LEFT JOIN (SELECT book_id, sum(quantity) AS ordered_qty FROM order_items GROUP BY book_id) o ON o.book_id = b.book_id
 WHERE b.category = '과학'
 ORDER BY b.book_id;
