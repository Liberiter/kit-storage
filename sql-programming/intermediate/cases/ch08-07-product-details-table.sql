-- runner: reset
-- 8장 8.1 «따라 하기» 5단계: 속성을 타입과 제약이 있는 열로 옮긴다 (3단계의 키 바로잡기를 앞에 다시 담는다)
UPDATE antipatterns.products
SET code = 'BK-016'
WHERE name = '빛나는 제주 여행 사전 (개정)';

ALTER TABLE antipatterns.products
ADD CONSTRAINT products_code_pkey PRIMARY KEY (code);

UPDATE antipatterns.product_attributes
SET attr_value = '456'
WHERE product_code = 'BK-004' AND attr_name = 'pages';

CREATE TABLE antipatterns.product_details (
    product_code text PRIMARY KEY REFERENCES antipatterns.products (code),
    pages integer NOT NULL CHECK (pages > 0),
    published date
);

INSERT INTO antipatterns.product_details (product_code, pages, published)
SELECT
    product_code,
    CAST(max(attr_value) FILTER (WHERE attr_name = 'pages') AS integer),
    CAST(max(attr_value) FILTER (WHERE attr_name = 'published') AS date)
FROM antipatterns.product_attributes
GROUP BY product_code;

SELECT
    count(*) AS 상품수,
    round(avg(pages)) AS 평균쪽수,
    count(published) AS 출간일있음
FROM antipatterns.product_details;

SELECT product_code AS 상품코드, pages AS 쪽수, published AS 출간일
FROM antipatterns.product_details
WHERE product_code IN ('BK-003', 'BK-004')
ORDER BY product_code;
