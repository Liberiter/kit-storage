-- runner: reset
-- 8장 «복습 exercise» 3 해설 (7장 — 제약 설계): 걸리는 줄을 먼저 고치고 CHECK 를 건 뒤 막히는지 본다
SELECT count(*) AS 고칠줄수
FROM antipatterns.products
WHERE status NOT IN ('active', 'inactive', 'soldout');

UPDATE antipatterns.products
SET status = 'active'
WHERE status IN ('Active', 'ACTIVE', '활성');

ALTER TABLE antipatterns.products
ADD CONSTRAINT products_status_allowed
CHECK (status IN ('active', 'inactive', 'soldout'));

INSERT INTO antipatterns.products (code, name, tags, price, status, created_on)
VALUES ('BK-017', '새로 들어온 책', '에세이', 12000, 'Active', '2025-04-01');
