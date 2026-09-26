-- 8장 8.1 «문제 상황»: 「교양」 태그 찾기(LIKE 가 교양과학까지 잡는다)와 쪽수 평균(글자 값에 막힌다)
SELECT code, name, tags
FROM antipatterns.products
WHERE tags LIKE '%교양%'
ORDER BY code;

SELECT avg(CAST(attr_value AS integer)) AS 평균쪽수
FROM antipatterns.product_attributes
WHERE attr_name = 'pages';
