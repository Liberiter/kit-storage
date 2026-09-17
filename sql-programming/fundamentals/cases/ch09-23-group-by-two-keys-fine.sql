-- 9.2 왜 그럴까요: 그룹 키를 늘리면 그룹이 잘게 쪼개진다 (제목까지 넣으면 한 권씩)
SELECT category AS 분야, title AS 제목, count(*) AS 권수
FROM books
GROUP BY category, title
ORDER BY 분야, 제목
LIMIT 5;
