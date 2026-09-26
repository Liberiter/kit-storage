-- 9장 9.1 «따라 하기» 1단계: 세션 시간대를 바꾸면 같은 값이 다른 시각으로 보인다 (저장된 값은 그대로)
SHOW timezone;
SELECT view_id, viewed_at FROM page_views WHERE view_id = 4;
SET timezone TO 'Asia/Seoul';
SELECT view_id, viewed_at FROM page_views WHERE view_id = 4;
RESET timezone;
SHOW timezone;
