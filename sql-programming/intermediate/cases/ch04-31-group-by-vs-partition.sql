-- 4장 4.3 «왜 그럴까요»: GROUP BY 는 행을 접고 PARTITION BY 는 행을 남긴다
-- (한 블록에 질의 둘)
SELECT category AS 분야, count(*) AS 권수
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
GROUP BY category
ORDER BY category;

SELECT category AS 분야, count(*) OVER (PARTITION BY category) AS "분야 권수"
FROM books
WHERE stock = 0
    AND category IN ('에세이', '요리')
ORDER BY category, book_id;
