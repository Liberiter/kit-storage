-- 3장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값" 쌍이다.
-- (books 320행·8열, category 8종 등 2장이 이미 고정한 주장은 ch02-26이 담당한다.)
-- (exercise 3 지문의 출간일 범위는 값이 날짜라 ch03-43-world-claims-text로 나눴다.)
--  · 3.1 따라 하기 2·3단계 / 다수: 여행 분야 도서 36
--  · 3.1 따라 하기 4단계: 정가 41000원 이상 11
--  · 3.1 왜 그럴까요: WHERE 없는 조회 320, '만화' 분야 0
--  · 3.1 흔한 실수: '여행 '(뒤 공백)과 일치하는 행 0
--  · 3.1 practice: 요리 분야 44, 쪽수 700 초과 30
--  · 3.2 따라 하기: 9000원 이하 13, 여행 아닌 책 284, 25000~30000원 59,
--    여행·요리 80, 제목에 '제주' 4, '한 권으로 읽는'으로 시작 32
--  · 3.2 왜 그럴까요: 25000~30000원 구간의 서로 다른 정가 11(양 끝 포함),
--    BETWEEN 30000 AND 25000 → 0
--  · 3.2 흔한 실수: title = '%제주%' → 0, title LIKE '제주' → 0
--  · 3.2 practice: 1만 원 미만 21, 제목에 '사전' 41
--  · 3.3 따라 하기: 여행 & 12000원 이하 6, 1만~4만 원 밖 38,
--    여행 & 10000~25000 & '제주' 3
--  · 3.3 왜 그럴까요: 괄호 없는 질의 40, 괄호 있는 질의 8
--  · 3.3 흔한 실수: category = '여행' AND category = '요리' → 0
--  · 3.3 practice: 에세이 & 1만 원 이하 3, (요리|어린이) & 1만 원 미만 7
--  · exercise 1~4: 8000원 이하 6, 제목이 '노트'로 끝남 43,
--    2025-01-01 이후 출간 15, (여행|요리) & 2만 원 이상 48
--  · 복습 exercise: 여행 & 3만 원 이상 9종, 그 저자 9명(중복 없음)
--  · problem 1~3: 여행 & 2만 원 이하 14,
--    (어린이|요리) & 1만~2만 원 & 재고 1권 이상 20, (여행|요리) & 15000원 이하 27,
--    problem 2의 '재고 0 초과'로 바꿔도 20, problem 3 채점 포인트의 오답 질의 52
--  · 그 밖의 본문 주장: 3.3 왜 그럴까요의 '싼 요리책 4종',
--    3.2 practice 1의 9500원 도서 8종, exercise 1의 8000원 미만 0종,
--    3.2 practice 2의 '사전으로 끝나는' 41종, exercise 3의 2025-01-01 출간 0종,
--    3.3 practice 2 해설의 괄호 없는 변형 47종과 IN 형태 7종,
--    exercise 1 채점 포인트의 '따옴표 붙인 숫자도 동작한다' 6종,
--    exercise 2 채점 포인트의 title = '%노트' 0종,
--    exercise 4 해설의 괄호 없는 변형 62종(= 여행 36 + 요리 & 20000원 이상 26),
--    problem 2 채점 포인트의 괄호 없는 변형 51종,
--    problem 3 지문의 동료 질의(여행 AND 요리 AND 15000원 이하) 0종
SELECT '여행 분야 도서 수' AS claim,
       (SELECT count(*) FROM books WHERE category = '여행') AS value
UNION ALL
SELECT '요리 분야 도서 수', (SELECT count(*) FROM books WHERE category = '요리')
UNION ALL
SELECT '여행 분야가 아닌 도서 수', (SELECT count(*) FROM books WHERE category <> '여행')
UNION ALL
SELECT 'books 전체 행 수', (SELECT count(*) FROM books)
UNION ALL
SELECT '만화 분야 도서 수', (SELECT count(*) FROM books WHERE category = '만화')
UNION ALL
SELECT '분야가 ''여행 ''(뒤 공백)인 도서 수', (SELECT count(*) FROM books WHERE category = '여행 ')
UNION ALL
SELECT '정가 41000원 이상 도서 수', (SELECT count(*) FROM books WHERE price >= 41000)
UNION ALL
SELECT '쪽수 700 초과 도서 수', (SELECT count(*) FROM books WHERE page_count > 700)
UNION ALL
SELECT '정가 9000원 이하 도서 수', (SELECT count(*) FROM books WHERE price <= 9000)
UNION ALL
SELECT '정가 8000원 이하 도서 수', (SELECT count(*) FROM books WHERE price <= 8000)
UNION ALL
SELECT '정가 10000원 미만 도서 수', (SELECT count(*) FROM books WHERE price < 10000)
UNION ALL
SELECT '정가 25000~30000원 도서 수',
       (SELECT count(*) FROM books WHERE price BETWEEN 25000 AND 30000)
UNION ALL
SELECT '그 구간의 서로 다른 정가 수',
       (SELECT count(DISTINCT price) FROM books WHERE price BETWEEN 25000 AND 30000)
UNION ALL
SELECT '그 구간에 정가 25000원 도서 수', (SELECT count(*) FROM books WHERE price = 25000)
UNION ALL
SELECT '그 구간에 정가 30000원 도서 수', (SELECT count(*) FROM books WHERE price = 30000)
UNION ALL
SELECT 'BETWEEN 30000 AND 25000 도서 수',
       (SELECT count(*) FROM books WHERE price BETWEEN 30000 AND 25000)
UNION ALL
SELECT '여행 또는 요리 분야 도서 수',
       (SELECT count(*) FROM books WHERE category IN ('여행', '요리'))
UNION ALL
SELECT '제목에 ''제주''가 든 도서 수', (SELECT count(*) FROM books WHERE title LIKE '%제주%')
UNION ALL
SELECT '제목이 ''%제주%''와 같은 도서 수', (SELECT count(*) FROM books WHERE title = '%제주%')
UNION ALL
SELECT 'LIKE ''제주''에 걸리는 도서 수', (SELECT count(*) FROM books WHERE title LIKE '제주')
UNION ALL
SELECT '''한 권으로 읽는''으로 시작하는 도서 수',
       (SELECT count(*) FROM books WHERE title LIKE '한 권으로 읽는%')
UNION ALL
SELECT '제목이 ''노트''로 끝나는 도서 수', (SELECT count(*) FROM books WHERE title LIKE '%노트')
UNION ALL
SELECT '제목에 ''사전''이 든 도서 수', (SELECT count(*) FROM books WHERE title LIKE '%사전%')
UNION ALL
SELECT '여행 & 12000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행' AND price <= 12000)
UNION ALL
SELECT '정가가 10000~40000원 밖인 도서 수',
       (SELECT count(*) FROM books WHERE NOT (price BETWEEN 10000 AND 40000))
UNION ALL
SELECT '여행 & 10000~25000 & 제목에 제주',
       (SELECT count(*) FROM books
         WHERE category = '여행' AND price BETWEEN 10000 AND 25000
           AND title LIKE '%제주%')
UNION ALL
SELECT '괄호 없는 OR/AND 질의의 행 수',
       (SELECT count(*) FROM books
         WHERE category = '여행' OR category = '요리' AND price <= 10000)
UNION ALL
SELECT '괄호 있는 OR/AND 질의의 행 수',
       (SELECT count(*) FROM books
         WHERE (category = '여행' OR category = '요리') AND price <= 10000)
UNION ALL
SELECT '여행이면서 동시에 요리인 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행' AND category = '요리')
UNION ALL
SELECT '에세이 & 10000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '에세이' AND price <= 10000)
UNION ALL
SELECT '(요리|어린이) & 10000원 미만 도서 수',
       (SELECT count(*) FROM books
         WHERE (category = '요리' OR category = '어린이') AND price < 10000)
UNION ALL
SELECT '2025-01-01 이후 출간 도서 수',
       (SELECT count(*) FROM books WHERE published_date >= '2025-01-01')
UNION ALL
SELECT '(여행|요리) & 20000원 이상 도서 수',
       (SELECT count(*) FROM books WHERE category IN ('여행', '요리') AND price >= 20000)
UNION ALL
SELECT '여행 & 30000원 이상 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행' AND price >= 30000)
UNION ALL
SELECT '그 도서들의 서로 다른 저자 수',
       (SELECT count(DISTINCT author) FROM books WHERE category = '여행' AND price >= 30000)
UNION ALL
SELECT '여행 & 20000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '여행' AND price <= 20000)
UNION ALL
SELECT '(어린이|요리) & 1만~2만 & 재고 1+',
       (SELECT count(*) FROM books
         WHERE category IN ('어린이', '요리') AND price BETWEEN 10000 AND 20000
           AND stock >= 1)
UNION ALL
SELECT '(여행|요리) & 15000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category IN ('여행', '요리') AND price <= 15000)
UNION ALL
SELECT '요리 & 10000원 이하 도서 수',
       (SELECT count(*) FROM books WHERE category = '요리' AND price <= 10000)
UNION ALL
SELECT '정가 9500원 도서 수', (SELECT count(*) FROM books WHERE price = 9500)
UNION ALL
SELECT '정가 8000원 미만 도서 수', (SELECT count(*) FROM books WHERE price < 8000)
UNION ALL
SELECT '제목이 ''사전''으로 끝나는 도서 수', (SELECT count(*) FROM books WHERE title LIKE '%사전')
UNION ALL
SELECT '2025-01-01에 출간된 도서 수',
       (SELECT count(*) FROM books WHERE published_date = '2025-01-01')
UNION ALL
SELECT '(어린이|요리) & 1만~2만 & 재고 0 초과',
       (SELECT count(*) FROM books
         WHERE category IN ('어린이', '요리') AND price BETWEEN 10000 AND 20000
           AND stock > 0)
UNION ALL
SELECT 'problem 3의 괄호 없는 오답 질의 행 수',
       (SELECT count(*) FROM books
         WHERE category = '여행' OR category = '요리' AND price <= 15000)
UNION ALL
SELECT '3.3 practice 2의 괄호 없는 변형 행 수',
       (SELECT count(*) FROM books
         WHERE category = '요리' OR category = '어린이' AND price < 10000)
UNION ALL
SELECT 'IN 형태 (요리|어린이) & 10000원 미만',
       (SELECT count(*) FROM books
         WHERE category IN ('요리', '어린이') AND price < 10000)
UNION ALL
SELECT '정가를 ''8000''(따옴표)으로 비교한 행 수',
       (SELECT count(*) FROM books WHERE price <= '8000')
UNION ALL
SELECT '제목이 ''%노트''와 같은 도서 수', (SELECT count(*) FROM books WHERE title = '%노트')
UNION ALL
SELECT '요리 & 20000원 이상 도서 수',
       (SELECT count(*) FROM books WHERE category = '요리' AND price >= 20000)
UNION ALL
SELECT 'exercise 4의 괄호 없는 변형 행 수',
       (SELECT count(*) FROM books
         WHERE category = '여행' OR category = '요리' AND price >= 20000)
UNION ALL
SELECT 'problem 2의 괄호 없는 변형 행 수',
       (SELECT count(*) FROM books
         WHERE category = '어린이' OR category = '요리'
           AND price BETWEEN 10000 AND 20000 AND stock >= 1)
UNION ALL
SELECT 'problem 3 지문 동료 질의의 행 수',
       (SELECT count(*) FROM books
         WHERE category = '여행' AND category = '요리' AND price <= 15000);
