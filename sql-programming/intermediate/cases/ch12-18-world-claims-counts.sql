-- 12장 주장 케이스 (정수) — 본문에 블록으로 등장하지 않는 world 의 수치·사실
--   1번 책 재고 → 12.1 «따라 하기» 3단계·«왜 그럴까요», 12.2 «따라 하기»·«흔한 실수»의 두 터미널 표에서 처음 읽는 5
--   4번 책 재고 → 12.2 «practice» 1·2 「4번 책(재고 5권)」, 12.2 «흔한 실수» [주의]의 교착 상태 장면, 연습하기 exercise 1 (나)·(다)
--   4번 책이 여행 분야 → 연습하기 exercise 3 「여행 분야의 4번 책」
--   6번 책 재고 → 12.1 «practice» 2 「6번 책(재고 1)」, 연습하기 exercise 2 「재고가 1권」, 도전하기 problem 1
--   처음 상태 품절 도서 수 → 12.1 «practice» 2 풀이 「처음 상태의 품절 도서는 27권」, 연습하기 exercise 1 (가) 27
--   book_supply 의 2번 책 행 수 → 복습 exercise 1 「2번 책은 아직 공급 정보(`book_supply`)가 없습니다」
--   orders·order_items 행 수 → 도전하기 problem 1 「처음 상태의 주문은 620건, 주문 항목은 1243건」
SELECT '1번 책 재고' AS 주장, stock AS 실측값 FROM books WHERE book_id = 1
UNION ALL
SELECT '4번 책 재고', stock FROM books WHERE book_id = 4
UNION ALL
SELECT '4번 책이 여행 분야인 행 수', count(*)::integer
FROM books WHERE book_id = 4 AND category = '여행'
UNION ALL
SELECT '6번 책 재고', stock FROM books WHERE book_id = 6
UNION ALL
SELECT '처음 상태 품절 도서 수', count(*)::integer FROM books WHERE stock = 0
UNION ALL
SELECT 'book_supply 의 2번 책 행 수', count(*)::integer
FROM book_supply WHERE book_id = 2
UNION ALL
SELECT 'orders 행 수', count(*)::integer FROM orders
UNION ALL
SELECT 'order_items 행 수', count(*)::integer FROM order_items;
