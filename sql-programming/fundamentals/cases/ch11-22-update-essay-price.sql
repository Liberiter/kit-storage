-- runner: reset
-- 11.2 따라 하기 5단계 — 센 만큼만 바뀌었는지 확인한다
UPDATE books SET price = price + 1000 WHERE category = '에세이';

SELECT count(*) AS 권수, min(price) AS 최저가, max(price) AS 최고가
FROM books
WHERE category = '에세이';
