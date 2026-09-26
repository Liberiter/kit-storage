-- 9장 9.3 «흔한 실수» 1: 0번째·범위 밖 첨자는 오류 없이 널
SELECT book_id, tags[0] AS 영번째, tags[1] AS 첫번째, tags[7] AS 일곱번째
FROM book_meta
WHERE book_id = 1;
