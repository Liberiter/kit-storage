-- 입장 점검 문항 1 참조 해답 (entry_check.sh --reference 가 쓴다)
SELECT title, price
FROM books
WHERE category = '과학' AND price >= 20000
ORDER BY price DESC, title;
