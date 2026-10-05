-- kit smoke: 큰 값의 저장 — 발췌(excerpt)의 길이·저장 크기·압축 방식이 책마다 갈린다
SELECT book_id, octet_length(excerpt) AS bytes, pg_column_size(excerpt) AS stored,
       coalesce(pg_column_compression(excerpt), '-') AS compression
  FROM book_contents
 WHERE book_id IN (1, 2, 7, 14, 100, 150)
 ORDER BY book_id;
