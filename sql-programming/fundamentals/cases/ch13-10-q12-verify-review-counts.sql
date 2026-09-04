-- 13장 exit assessment 문항 12 해설: 그룹으로 묶기 전에 내는 검증 질의
SELECT count(*) AS 리뷰수, count(comment) AS "내용 있는 리뷰" FROM reviews;
