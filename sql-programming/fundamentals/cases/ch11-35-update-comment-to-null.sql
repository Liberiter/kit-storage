-- runner: reset
-- 11.3 흔한 실수 — 값 하나를 비우는 것은 DELETE가 아니라 UPDATE다
SELECT
    review_id AS 리뷰번호,
    rating AS 별점,
    COALESCE(comment, '(내용 없음)') AS "한 줄평"
FROM reviews
WHERE review_id = 1;

UPDATE reviews SET comment = NULL WHERE review_id = 1;

SELECT
    review_id AS 리뷰번호,
    rating AS 별점,
    COALESCE(comment, '(내용 없음)') AS "한 줄평"
FROM reviews
WHERE review_id = 1;
