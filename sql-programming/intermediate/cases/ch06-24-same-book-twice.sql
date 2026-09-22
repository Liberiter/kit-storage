-- 연습하기 exercise 2 — 한 주문에 같은 책이 두 칸에 들어간 줄이 있는지 확인한다
SELECT count(*) AS 겹치는줄
FROM legacy.sales_ledger
WHERE "도서1" = "도서2" OR "도서1" = "도서3" OR "도서2" = "도서3";
