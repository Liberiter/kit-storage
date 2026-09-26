-- 9장 9.3 «따라 하기» 3단계: @> 는 모두 담고 있는가, && 는 하나라도 겹치는가
SELECT
    count(*) FILTER (WHERE tags @> ARRAY['여행', '사진많음']) AS 둘다,
    count(*) FILTER (WHERE tags && ARRAY['여행', '사진많음']) AS 하나라도
FROM book_meta;
