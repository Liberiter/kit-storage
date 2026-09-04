-- 6장 본문이 인용하는 world 수치 주장. 각 행이 "주장 → 실측값" 쌍이다.
-- 출력 블록이 없어 러너 대조에서 빠지는 주장들을 여기서 고정한다 (D-017·D-021).
--  · 들어가며·6.1 문제 상황: order_items 1243행, books 320행, orders 620건,
--    customers 150명
--  · 6.1 practice 1: 금액의 최댓값 126000
--  · (본문 대응 없음 — 회귀 방어용 초과 고정) 수량 값의 가짓수 3.
--    본문 어디도 "수량이 세 가지"라고 말하지 않는다. order_items의 수량 분포가
--    바뀌면 6.1 따라 하기 1단계의 출력이 조용히 달라지므로 함께 고정해 둔다.
--  · 6.1 따라 하기 2단계·practice 2: 발송된 주문 476건, 소요일 최대 4·최소 0,
--    발송일이 없는 주문 144건
--  · 6.1 따라 하기 4단계: 광고 수신 동의 93명·비동의 57명
--  · 6.1 흔한 실수·복습 exercise: price / 1000 값의 가짓수 35,
--    price / 10000 값의 가짓수 5, 정가 최대 42000·최소 8000
--  · 6.2 따라 하기 5단계·practice 2: 2025년 출간 7종(BETWEEN으로 세도 7종),
--    2024년 출간 9종
--  · 6.3 따라 하기 2단계·practice 1: 제목 글자 수 최대 19·최소 6
--  · exercise 1: 수량이 3인 주문 항목 169건
--  · exercise 2: 소요일이 4일인 주문 79건
--  · problem 1: 여행 분야 36종, 라벨이 23글자인 책 5종(채점 포인트의 "동점이
--    딱 다섯 줄")
--  · problem 2: 금액이 10만 원 이상인 주문 항목 26건
SELECT 'order_items 전체 행 수' AS claim,
       (SELECT count(*) FROM order_items) AS value
UNION ALL
SELECT 'books 전체 행 수', (SELECT count(*) FROM books)
UNION ALL
SELECT 'orders 전체 행 수', (SELECT count(*) FROM orders)
UNION ALL
SELECT 'customers 전체 행 수', (SELECT count(*) FROM customers)
UNION ALL
SELECT 'quantity 값의 가짓수', (SELECT count(DISTINCT quantity) FROM order_items)
UNION ALL
SELECT '주문 항목 금액(quantity * unit_price)의 최댓값',
       (SELECT max(quantity * unit_price) FROM order_items)
UNION ALL
SELECT '금액이 100000 이상인 주문 항목 수',
       (SELECT count(*) FROM order_items WHERE quantity * unit_price >= 100000)
UNION ALL
SELECT '수량이 3인 주문 항목 수',
       (SELECT count(*) FROM order_items WHERE quantity = 3)
UNION ALL
SELECT '발송일이 있는 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date IS NOT NULL)
UNION ALL
SELECT '발송일이 없는 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date IS NULL)
UNION ALL
SELECT '발송 소요일의 최댓값', (SELECT max(shipped_date - order_date) FROM orders)
UNION ALL
SELECT '발송 소요일의 최솟값', (SELECT min(shipped_date - order_date) FROM orders)
UNION ALL
SELECT '발송 소요일이 4일인 주문 수',
       (SELECT count(*) FROM orders WHERE shipped_date - order_date = 4)
UNION ALL
SELECT '광고 수신에 동의한 고객 수',
       (SELECT count(*) FROM customers WHERE marketing_opt_in)
UNION ALL
SELECT '광고 수신에 동의하지 않은 고객 수',
       (SELECT count(*) FROM customers WHERE NOT marketing_opt_in)
UNION ALL
SELECT 'price / 1000 값의 가짓수', (SELECT count(DISTINCT price / 1000) FROM books)
UNION ALL
SELECT 'price / 10000 값의 가짓수',
       (SELECT count(DISTINCT price / 10000) FROM books)
UNION ALL
SELECT '정가의 최댓값', (SELECT max(price) FROM books)
UNION ALL
SELECT '정가의 최솟값', (SELECT min(price) FROM books)
UNION ALL
SELECT '2025년에 펴낸 책의 수 (형변환 + LIKE)',
       (SELECT count(*) FROM books
        WHERE CAST(published_date AS text) LIKE '2025%')
UNION ALL
SELECT '2025년에 펴낸 책의 수 (BETWEEN)',
       (SELECT count(*) FROM books
        WHERE published_date BETWEEN '2025-01-01' AND '2025-12-31')
UNION ALL
SELECT '2024년에 펴낸 책의 수',
       (SELECT count(*) FROM books
        WHERE CAST(published_date AS text) LIKE '2024%')
UNION ALL
SELECT '제목 글자 수의 최댓값', (SELECT max(length(title)) FROM books)
UNION ALL
SELECT '제목 글자 수의 최솟값', (SELECT min(length(title)) FROM books)
UNION ALL
SELECT '여행 분야 도서 수', (SELECT count(*) FROM books WHERE category = '여행')
UNION ALL
SELECT '여행 분야에서 라벨이 23글자인 책의 수',
       (SELECT count(*) FROM books
        WHERE category = '여행'
          AND length(title || ' / ' || author) = 23);
