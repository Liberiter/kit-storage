-- 6.3 흔한 실수: 글자 함수에 숫자 열을 넘기면 함수가 없다는 오류가 난다
SELECT length(price) AS 결과 FROM books LIMIT 1;
