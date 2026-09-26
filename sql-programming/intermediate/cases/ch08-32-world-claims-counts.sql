-- 8장 주장 케이스 (정수) — 본문에 코드 블록으로 등장하지 않는다.
-- 출력 블록에서 여러분이 셀 수 없는 수치 주장을 한 표에 모아 고정한다 (D-017·D-021).
-- 뒷받침하는 자리:
--   antipatterns 스키마의 표 4개 → «왜 배우나요»의 「표 네 개」
--   소문자 active 로 적힌 상품 8 → «복습 exercise» 1 «채점 포인트»의 「여덟 개만 세어집니다」
--   product_attributes 에 BK-016 으로 적힌 줄 0 → 8.1 «따라 하기» 5단계 해설의
--     「새 코드 BK-016 으로 적힌 줄이 없기 때문」
--   2번 책의 주문 항목 5줄·4번 책의 주문 항목 7줄 → 8.2 «따라 하기» 2단계 해설의
--     「주문 항목 다섯 줄과 리뷰 다섯 개」, 8.2 «왜 그럴까요»의 m = 5, m = 7
--   books 의 책 320권 → 8.2 «따라 하기» 4단계의 「320권 전부」
--   이름이 서도윤인 고객 4명·정지아인 고객 3명 → 8.2 «따라 하기» 6단계 해설의
--     「서도윤이라는 고객이 네 명」, 「정지아 님의 35건도 마찬가지로 여러 사람의 합」
--   고객 1번에 주문과 리뷰를 곧바로 이은 줄 24 → 8.2 «practice» 1 해설
--   reviews 의 줄 520 → «연습하기» exercise 3 «채점 포인트»의 「리뷰 표의 줄 수」
--   comments 의 외래키 0개 → 8.1 «흔한 실수»의 「댓글 표가 회원 표를 외래키로
--     가리키고 있지 않기 때문」, 8.1 «practice» 2 해설
--   books 에 쓰인 분류 8가지 → «연습하기» exercise 3 «채점 포인트»의 「여덟 분류 모두
--     팔린 책도 리뷰도 있어서 지금은 줄이 빠지지 않습니다」 (출력의 8행이 전체 분류임)
--   최하윤 회원의 전화번호 칸 가운데 값이 있는 칸 0 → 8.2 «흔한 실수»의 「최하윤 님은
--     번호가 하나도 없으니」 (phone3 은 어느 출력에도 나오지 않는다)
SELECT 'antipatterns 스키마의 표 수' AS 주장, count(*) AS 실측값
FROM information_schema.tables
WHERE table_schema = 'antipatterns'
UNION ALL
SELECT '소문자 active 로 적힌 상품 수', count(*)
FROM antipatterns.products WHERE status = 'active'
UNION ALL
SELECT 'product_attributes 에 BK-016 으로 적힌 줄 수', count(*)
FROM antipatterns.product_attributes WHERE product_code = 'BK-016'
UNION ALL
SELECT '2번 책의 주문 항목 줄 수', count(*)
FROM order_items WHERE book_id = 2
UNION ALL
SELECT '4번 책의 주문 항목 줄 수', count(*)
FROM order_items WHERE book_id = 4
UNION ALL
SELECT 'books 의 책 수', count(*) FROM books
UNION ALL
SELECT '이름이 서도윤인 고객 수', count(*)
FROM customers WHERE name = '서도윤'
UNION ALL
SELECT '이름이 정지아인 고객 수', count(*)
FROM customers WHERE name = '정지아'
UNION ALL
SELECT '고객 1번에 주문과 리뷰를 곧바로 이은 줄 수', count(*)
FROM customers AS c
INNER JOIN orders AS o ON o.customer_id = c.customer_id
INNER JOIN reviews AS r ON r.customer_id = c.customer_id
WHERE c.customer_id = 1
UNION ALL
SELECT 'reviews 의 줄 수', count(*) FROM reviews
UNION ALL
SELECT 'comments 의 외래키 수', count(*)
FROM pg_constraint
WHERE conrelid = 'antipatterns.comments'::regclass AND contype = 'f'
UNION ALL
SELECT 'books 에 쓰인 분류 수', count(DISTINCT category) FROM books
UNION ALL
SELECT '최하윤 회원의 번호가 적힌 칸 수',
       count(phone1) + count(phone2) + count(phone3)
FROM antipatterns.members WHERE name = '최하윤';
