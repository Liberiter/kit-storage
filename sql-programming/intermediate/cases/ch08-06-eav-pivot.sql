-- 8장 8.1 «따라 하기» 4단계: 속성 이름별 줄 수, 그리고 1장의 FILTER 로 한 줄에 되돌린 모습
SELECT attr_name AS 속성, count(*) AS 줄수
FROM antipatterns.product_attributes
GROUP BY attr_name
ORDER BY 줄수 DESC, 속성;

SELECT
    product_code AS 상품코드,
    max(attr_value) FILTER (WHERE attr_name = 'pages') AS 쪽수,
    max(attr_value) FILTER (WHERE attr_name = 'published') AS 출간일,
    max(attr_value) FILTER (WHERE attr_name = 'age') AS 대상연령
FROM antipatterns.product_attributes
GROUP BY product_code
ORDER BY product_code;
