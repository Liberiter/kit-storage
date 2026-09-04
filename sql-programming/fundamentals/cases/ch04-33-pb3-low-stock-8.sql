-- 4장 problem 3 (a) 해설: 같은 질의를 LIMIT 8로 바꾸면 앞 5줄의 내용이 달라진다
SELECT title, stock FROM books WHERE category = '어린이' ORDER BY stock LIMIT 8;
