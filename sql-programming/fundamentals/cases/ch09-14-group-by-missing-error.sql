-- 9.2 문제 상황: 그룹 없이 열과 집계를 함께 고르면 오류 (오류 기대, exit 3)
SELECT category AS 분야, count(*) AS 권수 FROM books;
