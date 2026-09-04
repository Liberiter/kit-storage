-- 5.1 흔한 실수 — `comment = ''`는 0행. NULL은 빈 문자열이 아니다
SELECT review_id, rating, comment FROM reviews WHERE comment = '';
