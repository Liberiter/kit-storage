-- 9장 9.3 «practice» 2: 태그가 여섯 개 붙은 책
SELECT book_id, tags
FROM book_meta
WHERE cardinality(tags) = 6
ORDER BY book_id;
