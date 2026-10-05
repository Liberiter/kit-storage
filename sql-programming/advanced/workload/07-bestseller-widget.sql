-- 워크로드 7 — 분야별 베스트셀러 위젯: 과학 분야 책마다 판매 건수를 세어 많은 차례로 5권 (1번).
SELECT b.title,
       (SELECT count(*) FROM sales s WHERE s.book_id = b.book_id) AS sold
  FROM books b
 WHERE b.category = '과학'
 ORDER BY sold DESC, b.title
 LIMIT 5;
