-- runner: reset
-- 8장 «연습하기» exercise 4 해설: EAV 는 속성 이름의 오타를 막지 못하고, 되돌린 줄에서 값이 사라진다
INSERT INTO antipatterns.product_attributes (
    product_code, attr_name, attr_value
)
VALUES ('BK-005', 'publish', '2024-04-01');

SELECT
    product_code AS 상품코드,
    max(attr_value) FILTER (WHERE attr_name = 'published') AS 출간일
FROM antipatterns.product_attributes
WHERE product_code = 'BK-005'
GROUP BY product_code;
