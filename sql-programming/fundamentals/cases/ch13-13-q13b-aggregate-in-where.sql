-- 13장 exit assessment 문항 13 (나) 지문: 집계 함수를 WHERE에 쓴 오류 (오류 기대, exit 3)
SELECT
    book_id AS 도서번호,
    count(*) AS 리뷰수
FROM reviews
WHERE count(*) >= 5
GROUP BY book_id
ORDER BY 리뷰수 DESC, 도서번호;
