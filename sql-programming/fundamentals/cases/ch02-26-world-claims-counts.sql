-- 2장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값" 쌍이다.
-- (books 전체 행 수 320은 01-counts 케이스가 담당한다.)
--  · 2.1 개념/2.3: books는 열 8개, 320행
--  · 2.3 따라 하기 1단계·practice 2: category 서로 다른 값 8, title 서로 다른 값 320
--  · 2.3 따라 하기 2단계: stock 서로 다른 값 10
--  · 2.3 흔한 실수: book_id 서로 다른 값 320 (DISTINCT가 한 행도 줄이지 못한다)
--  · 2.3 왜 그럴까요 / exercise 4: (category, stock) 조합 80,
--    exercise 4 해설의 '재고 0인 요리책'·'재고 60인 어린이책' 존재
--  · exercise 3 / problem 3: author 서로 다른 값 197, (author, title) 조합 320
SELECT 'books 테이블의 열 개수' AS claim,
       (SELECT count(*) FROM information_schema.columns
         WHERE table_schema = 'public' AND table_name = 'books') AS value
UNION ALL
SELECT 'books 테이블의 행 수', (SELECT count(*) FROM books)
UNION ALL
SELECT 'category의 서로 다른 값 수', (SELECT count(DISTINCT category) FROM books)
UNION ALL
SELECT 'stock의 서로 다른 값 수', (SELECT count(DISTINCT stock) FROM books)
UNION ALL
SELECT 'author의 서로 다른 값 수', (SELECT count(DISTINCT author) FROM books)
UNION ALL
SELECT 'title의 서로 다른 값 수', (SELECT count(DISTINCT title) FROM books)
UNION ALL
SELECT 'book_id의 서로 다른 값 수', (SELECT count(DISTINCT book_id) FROM books)
UNION ALL
SELECT '(category, stock) 조합의 가짓수',
       (SELECT count(*) FROM (SELECT DISTINCT category, stock FROM books) t)
UNION ALL
SELECT '(author, title) 조합의 가짓수',
       (SELECT count(*) FROM (SELECT DISTINCT author, title FROM books) t)
UNION ALL
SELECT '재고가 0인 요리 분야 도서 수',
       (SELECT count(*) FROM books WHERE category = '요리' AND stock = 0)
UNION ALL
SELECT '재고가 60인 어린이 분야 도서 수',
       (SELECT count(*) FROM books WHERE category = '어린이' AND stock = 60)
UNION ALL
SELECT 'NULL이 든 열이 있는 books 행 수',
       (SELECT count(*) FROM books
         WHERE book_id IS NULL OR title IS NULL OR author IS NULL OR category IS NULL
            OR price IS NULL OR page_count IS NULL OR published_date IS NULL OR stock IS NULL);
