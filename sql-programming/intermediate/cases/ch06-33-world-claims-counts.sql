-- 6장 주장 케이스 — 본문이 인용하지만 출력 블록에 찍히지 않는 수치를 고정한다.
--   원장 줄 수 207            → 6.1 문제 상황 「2025년에 들어온 주문 ... 207건」,
--                                6.2 따라 하기 2단계 「207줄이 들어가려다」,
--                                6.2 따라 하기 4단계 「원장 207줄이」
--   2025년 밖 줄 0            → 같은 자리의 「2025년에 들어온 주문」
--   원장에 없는 2025년 주문 26 → 6.1 문제 상황 「한 건에 책이 세 종 이하인 207건」
--   서로 다른 이메일 76        → 6.2 문제 상황 「이런 줄이 일흔여섯 개 나옵니다」
--   단가가 둘 이상인 도서 0    → 6.1 왜 그럴까요 「도서 ──▶ 단가도 성립합니다」
--   골목길 기록 도서1 칸 0     → 6.1 따라 하기 1단계 「팔린 자리가 모두 도서2·도서3」
--   골목길 기록 도서2·3 칸 5   → 같은 자리
--   따옴표 없는 도서1 칸 207   → 6.1 문제 상황 「원장의 한글 이름은 감싸도 되고
--                                감싸지 않아도 됩니다」 (이 줄은 큰따옴표 없이
--                                한글 열 이름을 부른다 — 실행되는 것 자체가 증거)
SELECT '원장의 줄 수' AS 주장, count(*) AS 실측값
FROM legacy.sales_ledger
UNION ALL
SELECT '주문일이 2025년이 아닌 줄', count(*)
FROM legacy.sales_ledger
WHERE "주문일" NOT LIKE '2025.%'
UNION ALL
SELECT '2025년 주문 가운데 원장에 없는 것', count(*)
FROM orders
WHERE order_date BETWEEN '2025-01-01' AND '2025-12-31'
    AND NOT EXISTS (
        SELECT 1
        FROM legacy.sales_ledger
        WHERE legacy.sales_ledger."주문번호"
            = 'ORD-' || lpad(CAST(orders.order_id AS text), 5, '0')
    )
UNION ALL
SELECT '원장의 서로 다른 고객 이메일 수', count(DISTINCT "고객이메일")
FROM legacy.sales_ledger
UNION ALL
SELECT '단가가 둘 이상 적힌 도서', count(*)
FROM (
    SELECT 도서
    FROM (
        SELECT "도서1" AS 도서, "단가1" AS 단가
        FROM legacy.sales_ledger
        WHERE "도서1" IS NOT NULL
        UNION ALL
        SELECT "도서2", "단가2"
        FROM legacy.sales_ledger
        WHERE "도서2" IS NOT NULL
        UNION ALL
        SELECT "도서3", "단가3"
        FROM legacy.sales_ledger
        WHERE "도서3" IS NOT NULL
    ) AS pulled
    GROUP BY 도서
    HAVING count(DISTINCT 단가) > 1
) AS multi_priced
UNION ALL
SELECT '빛나는 골목길 기록이 도서1 칸에 적힌 줄', count(*)
FROM legacy.sales_ledger
WHERE "도서1" = '빛나는 골목길 기록'
UNION ALL
SELECT '빛나는 골목길 기록이 도서2 칸과 도서3 칸에 적힌 줄', count(*)
FROM legacy.sales_ledger
WHERE "도서2" = '빛나는 골목길 기록' OR "도서3" = '빛나는 골목길 기록'
UNION ALL
SELECT '따옴표 없이 부른 도서1 칸에 값이 있는 줄', count(*)
FROM legacy.sales_ledger
WHERE 도서1 IS NOT NULL;
