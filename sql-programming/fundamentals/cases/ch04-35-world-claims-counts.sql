-- 4장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값" 쌍이다.
-- (books 320행·8열, 여행 36종처럼 2·3장이 이미 고정한 주장도 4장 본문이 다시
--  인용하므로 여기에 함께 담는다.)
--  · 4.1 문제 상황·따라 하기 1~3단계: 8500원 이하 9, 그중 8000원 6·8500원 3
--  · 4.1 따라 하기 4단계: 여행 36, 여행 & 12000원 이하 6
--  · 4.1 따라 하기 5·6단계: 41000원 이상 11, 42000원 3·41500원 3·41000원 5
--  · 4.1 왜 그럴까요·흔한 실수: 가장 비싼 정가 42000, 가장 싼 정가 8000
--  · 4.1 practice: 750쪽 이상 9(그중 760쪽 5), 2026년 출간 8
--  · 4.2 문제 상황: 41500원 이상 6
--  · 4.2 따라 하기 4단계: 요리 & 9000원 이하 2
--  · 4.2 왜 그럴까요: book_id는 320행 모두 다르다, 42000원 세 권의 book_id 65·226·280
--  · 4.2 practice·exercise: 가장 적은 쪽수 120
--    (가장 이른/늦은 출간일은 값이 날짜라 이 표에서 뺐다 — 입력이 같은
--     ch03-43-world-claims-text가 두 값을 글자로 고정한다)
--  · exercise 4: 10000~20000원 106
--  · 복습 exercise: 여행 분야의 서로 다른 정가 26가지
--  · exercise 4: 2026년 출간 도서 여덟 종 중 10000~20000원은 1종뿐
--  · problem 1: 요리 44, 요리 & 재고 1권 이상 37
--  · problem 2: 2025-01-01 이후 출간 15 (3쪽의 마지막 줄이 그 15종의 끝이다)
--  · problem 3: 어린이 39, 그중 재고 0이 3종·재고 1이 4종
--  · 마무리 요약: OFFSET을 LIMIT 앞에 적어도 문법 오류가 아니다. 아래 마지막
--    행이 그 형태를 실제로 파싱·실행해 2행을 돌려주는 것으로 고정한다 (형태가
--    문법 오류가 되면 이 케이스 전체가 exit 3으로 실패한다).
SELECT 'books 전체 행 수' AS claim, (SELECT count(*) FROM books) AS value
UNION ALL
SELECT '정가 8500원 이하 도서 수', (SELECT count(*) FROM books WHERE price <= 8500)
UNION ALL
SELECT '정가 8000원 도서 수', (SELECT count(*) FROM books WHERE price = 8000)
UNION ALL
SELECT '정가 8500원 도서 수', (SELECT count(*) FROM books WHERE price = 8500)
UNION ALL
SELECT '가장 싼 정가', (SELECT min(price) FROM books)
UNION ALL
SELECT '가장 비싼 정가', (SELECT max(price) FROM books)
UNION ALL
SELECT '여행 분야 도서 수', (SELECT count(*) FROM books WHERE category = '여행')
UNION ALL
SELECT '여행 & 12000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행' AND price <= 12000)
UNION ALL
SELECT '정가 41000원 이상 도서 수', (SELECT count(*) FROM books WHERE price >= 41000)
UNION ALL
SELECT '정가 41500원 이상 도서 수', (SELECT count(*) FROM books WHERE price >= 41500)
UNION ALL
SELECT '정가 42000원 도서 수', (SELECT count(*) FROM books WHERE price = 42000)
UNION ALL
SELECT '정가 41500원 도서 수', (SELECT count(*) FROM books WHERE price = 41500)
UNION ALL
SELECT '정가 41000원 도서 수', (SELECT count(*) FROM books WHERE price = 41000)
UNION ALL
SELECT '쪽수 750쪽 이상 도서 수', (SELECT count(*) FROM books WHERE page_count >= 750)
UNION ALL
SELECT '쪽수 760쪽 도서 수', (SELECT count(*) FROM books WHERE page_count = 760)
UNION ALL
SELECT '가장 많은 쪽수', (SELECT max(page_count) FROM books)
UNION ALL
SELECT '가장 적은 쪽수', (SELECT min(page_count) FROM books)
UNION ALL
SELECT '2026-01-01 이후 출간 도서 수',
       (SELECT count(*) FROM books WHERE published_date >= '2026-01-01')
UNION ALL
SELECT '요리 & 9000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '요리' AND price <= 9000)
UNION ALL
SELECT 'book_id의 서로 다른 값 수', (SELECT count(DISTINCT book_id) FROM books)
UNION ALL
SELECT '''다시 쓰는 빵 이야기''의 book_id',
       (SELECT book_id FROM books WHERE title = '다시 쓰는 빵 이야기')
UNION ALL
SELECT '''밤에 읽는 채소''의 book_id',
       (SELECT book_id FROM books WHERE title = '밤에 읽는 채소')
UNION ALL
SELECT '''다시 쓰는 공룡 노트''의 book_id',
       (SELECT book_id FROM books WHERE title = '다시 쓰는 공룡 노트')
UNION ALL
SELECT '정가 10000~20000원 도서 수',
       (SELECT count(*) FROM books WHERE price BETWEEN 10000 AND 20000)
UNION ALL
SELECT '여행 분야의 서로 다른 정가 수',
       (SELECT count(DISTINCT price) FROM books WHERE category = '여행')
UNION ALL
SELECT '요리 & 재고 1권 이상 도서 수',
       (SELECT count(*) FROM books WHERE category = '요리' AND stock >= 1)
UNION ALL
SELECT '어린이 분야 도서 수', (SELECT count(*) FROM books WHERE category = '어린이')
UNION ALL
SELECT '어린이 & 재고 0 도서 수',
       (SELECT count(*) FROM books WHERE category = '어린이' AND stock = 0)
UNION ALL
SELECT '어린이 & 재고 1 도서 수',
       (SELECT count(*) FROM books WHERE category = '어린이' AND stock = 1)
UNION ALL
SELECT '2025-01-01 이후 출간 도서 수',
       (SELECT count(*) FROM books WHERE published_date >= '2025-01-01')
UNION ALL
SELECT '요리 분야 도서 수', (SELECT count(*) FROM books WHERE category = '요리')
UNION ALL
SELECT '2026년 출간 & 10000~20000원 도서 수',
       (SELECT count(*) FROM books
         WHERE published_date >= '2026-01-01' AND price BETWEEN 10000 AND 20000)
UNION ALL
SELECT 'OFFSET을 LIMIT 앞에 적은 질의의 행 수',
       (SELECT count(*) FROM (SELECT book_id FROM books
                               ORDER BY book_id OFFSET 2 LIMIT 2) t);
