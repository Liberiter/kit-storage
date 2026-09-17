-- 1장 1.2 «흔한 실수»: 단순 형태의 CASE 로는 널을 가려낼 수 없다
SELECT
    review_id AS 리뷰번호,
    CASE comment
        WHEN NULL THEN '내용 없음'
        ELSE '내용 있음'
    END AS "단순 형태",
    CASE
        WHEN comment IS NULL THEN '내용 없음'
        ELSE '내용 있음'
    END AS "검색 형태"
FROM reviews
WHERE review_id BETWEEN 1 AND 6
ORDER BY review_id;
