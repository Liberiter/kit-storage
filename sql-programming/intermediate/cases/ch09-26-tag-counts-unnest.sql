-- 9장 9.3 «따라 하기» 4단계: unnest 로 원소마다 한 줄을 만들고, 태그마다 책 수를 센다
SELECT book_id, unnest(tags) AS 태그 FROM book_meta WHERE book_id = 1;

WITH tagged AS (
    SELECT book_id, unnest(tags) AS 태그 FROM book_meta
)
SELECT 태그, count(*) AS 책수
FROM tagged
GROUP BY 태그
ORDER BY 책수 DESC, 태그
LIMIT 6;
