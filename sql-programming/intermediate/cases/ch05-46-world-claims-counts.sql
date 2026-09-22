-- 5장 주장 케이스 — 본문이 인용하지만 출력 블록에서 셀 수 없는 수치를 고정한다.
-- 뒷받침하는 자리는 cases/README.md 의 5장 절에 적었다.
SELECT '159 번 책의 재고' AS claim, stock AS value FROM books WHERE book_id = 159
UNION ALL
SELECT '124 번 책의 재고', stock FROM books WHERE book_id = 124
UNION ALL
SELECT '47 번 책의 재고', stock FROM books WHERE book_id = 47
UNION ALL
SELECT '조회 기록 행 수', count(*) FROM page_views
ORDER BY claim;
