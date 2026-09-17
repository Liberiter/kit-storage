-- 2장 2.2 «개념»의 상관 서브쿼리 예제 · 2.2 «따라 하기» 1단계 — EXISTS 로
-- 리뷰가 하나라도 달린 책을 센다 (두 자리의 입력이 바이트 동일하다)
SELECT count(*) AS 권수
FROM books
WHERE EXISTS (SELECT 1 FROM reviews WHERE reviews.book_id = books.book_id);
