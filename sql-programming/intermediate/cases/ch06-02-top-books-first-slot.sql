-- 6.1 문제 상황 — 도서1 칸만 세어 본 「많이 팔린 책」 (조용히 틀린 답)
SELECT "도서1" AS 도서, sum(CAST("수량1" AS integer)) AS 판매수량
FROM legacy.sales_ledger
WHERE "도서1" IS NOT NULL
GROUP BY "도서1"
ORDER BY 판매수량 DESC, 도서
LIMIT 5;
