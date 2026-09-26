-- 9장 9.1 «practice» 1: 첫 공급사 피드가 서울 시각으로 언제 들어왔는가
SELECT feed_id, received_at, received_at AT TIME ZONE 'Asia/Seoul' AS 서울시각
FROM supplier_feed
WHERE feed_date = '2026-08-25'
ORDER BY feed_id
LIMIT 3;
