-- 4장 problem 3 지문: 동료 질의 — 재고가 적은 어린이책 5종 (유일한 정렬 키가 없다)
SELECT title, stock FROM books WHERE category = '어린이' ORDER BY stock LIMIT 5;
