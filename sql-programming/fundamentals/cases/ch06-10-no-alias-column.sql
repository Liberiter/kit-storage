-- 6.1 흔한 실수: 계산해서 만든 열에 별칭이 없으면 머리글이 ?column?이 된다
-- (style.md R22의 의도된 반례 — D-025)
SELECT title, price / 1000 FROM books ORDER BY book_id LIMIT 3;
