-- runner: reset
-- 11.3 왜 그럴까요 — WHERE를 빠뜨린 DELETE는 모든 행을 지운다
DELETE FROM reviews;

SELECT count(*) AS 남은리뷰 FROM reviews;
