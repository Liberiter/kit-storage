-- 6.2 practice 1 풀이: 쪽수를 백 쪽 단위로 (형변환 후 나눗셈)
SELECT title, page_count, CAST(page_count AS numeric) / 100 AS "백 쪽 단위"
FROM books
ORDER BY book_id
LIMIT 5;
