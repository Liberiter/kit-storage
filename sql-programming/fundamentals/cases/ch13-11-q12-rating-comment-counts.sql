-- 13장 exit assessment 문항 12 해설: 별점별 리뷰 수와 내용 있는 리뷰 수
SELECT rating AS 별점, count(*) AS 리뷰수, count(comment) AS "내용 있는 리뷰"
FROM reviews
GROUP BY rating
HAVING count(*) >= 100
ORDER BY 별점;
