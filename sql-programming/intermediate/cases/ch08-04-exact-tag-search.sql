-- 8장 8.1 «따라 하기» 2단계: 쉼표를 앞뒤에 붙여 태그 하나를 정확히 찾는다
SELECT code, name, tags
FROM antipatterns.products
WHERE ',' || tags || ',' LIKE '%,교양,%'
ORDER BY code;
