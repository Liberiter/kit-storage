-- 5.2 문제 상황 — 리뷰 목록의 comment 칸이 군데군데 비어 있다
SELECT review_id, rating, comment FROM reviews ORDER BY review_id LIMIT 6;
