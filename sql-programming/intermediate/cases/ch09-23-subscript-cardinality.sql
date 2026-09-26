-- 9장 9.3 «따라 하기» 1단계: 첨자는 1부터, cardinality 는 원소 수
SELECT
    book_id,
    tags[1] AS 첫태그,
    tags[2] AS 둘째태그,
    cardinality(tags) AS 태그수
FROM book_meta
WHERE book_id <= 4
ORDER BY book_id;
