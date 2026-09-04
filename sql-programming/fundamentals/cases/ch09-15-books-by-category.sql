-- 9.2 따라 하기 1단계: 분야별 권수
-- 9.2 개념의 서식 규칙 예제(R30)와 입력이 같다(그 자리는 출력을 싣지 않는다)
SELECT category AS 분야, count(*) AS 권수
FROM books
GROUP BY category
ORDER BY 권수 DESC, 분야;
