-- 2장 2.3 흔한 실수: DISTINCT(category)의 괄호는 함수 호출이 아니다 (ch02-18과 결과가 같다)
SELECT DISTINCT(category), stock FROM books LIMIT 8;
