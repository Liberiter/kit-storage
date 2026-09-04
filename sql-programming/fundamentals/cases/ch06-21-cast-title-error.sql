-- 6.2 흔한 실수: 숫자로 읽을 수 없는 글자는 정수로 바꿀 수 없다 (오류 기대)
SELECT CAST(title AS integer) AS 결과 FROM books LIMIT 1;
