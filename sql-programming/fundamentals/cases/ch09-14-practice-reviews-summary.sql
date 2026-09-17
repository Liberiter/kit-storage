-- 9.1 practice 1 풀이: 리뷰 건수와 평균 별점
SELECT count(*) AS 리뷰수, round(avg(rating), 2) AS 평균별점 FROM reviews;
