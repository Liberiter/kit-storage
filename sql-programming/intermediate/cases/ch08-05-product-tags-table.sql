-- runner: reset
-- 8장 8.1 «따라 하기» 3단계: 키를 바로잡고, 교차 테이블을 만들어 채운 뒤 태그로 센다
UPDATE antipatterns.products
SET code = 'BK-016'
WHERE name = '빛나는 제주 여행 사전 (개정)';

ALTER TABLE antipatterns.products
ADD CONSTRAINT products_code_pkey PRIMARY KEY (code);

SELECT count(*) AS 다섯째칸이있는상품
FROM antipatterns.products
WHERE split_part(tags, ',', 5) <> '';

CREATE TABLE antipatterns.product_tags (
    product_code text NOT NULL REFERENCES antipatterns.products (code),
    tag text NOT NULL,
    PRIMARY KEY (product_code, tag)
);

INSERT INTO antipatterns.product_tags (product_code, tag)
SELECT code, split_part(tags, ',', 1)
FROM antipatterns.products
WHERE split_part(tags, ',', 1) <> ''
UNION ALL
SELECT code, split_part(tags, ',', 2)
FROM antipatterns.products
WHERE split_part(tags, ',', 2) <> ''
UNION ALL
SELECT code, split_part(tags, ',', 3)
FROM antipatterns.products
WHERE split_part(tags, ',', 3) <> ''
UNION ALL
SELECT code, split_part(tags, ',', 4)
FROM antipatterns.products
WHERE split_part(tags, ',', 4) <> '';

SELECT tag AS 태그, count(*) AS 상품수
FROM antipatterns.product_tags
WHERE tag IN ('교양', '교양과학', '여행', '국내여행')
GROUP BY tag
ORDER BY tag;

SELECT product_code AS 상품코드
FROM antipatterns.product_tags
WHERE tag = '교양'
ORDER BY product_code;
