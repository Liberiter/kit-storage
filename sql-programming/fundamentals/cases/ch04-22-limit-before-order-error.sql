-- 4장 4.2 흔한 실수: LIMIT을 ORDER BY 앞에 두면 문법 오류 (오류 기대)
SELECT title FROM books LIMIT 5 ORDER BY price;
