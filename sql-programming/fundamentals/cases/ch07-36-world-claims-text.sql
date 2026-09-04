-- 7장 본문이 인용하는 키 구성 주장. 각 행이 "주장 → 실측값(열 이름)" 쌍이다.
-- 수치 주장(ch07-35)과 값의 타입이 달라 케이스를 나눴다 (pipeline "주장 케이스").
--  · 7.1 개념·따라 하기·흔한 실수: 다섯 테이블의 기본키 열, order_items만 두 열
--  · 7.2 개념·따라 하기 1·3·4단계: 각 테이블의 외래키 열과 참조 방향
--  · 7.2 왜 그럴까요·흔한 실수: reviews의 외래키 셋 중 널을 허용하는 것은
--    order_id 하나뿐이다
SELECT t.claim, t.value
FROM (
  SELECT 1 AS ord, 'customers의 기본키 열' AS claim,
         (SELECT string_agg(a.attname, ', ' ORDER BY k.ord)
            FROM pg_constraint c,
                 unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord),
                 pg_attribute a
           WHERE c.conrelid = 'customers'::regclass AND c.contype = 'p'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum) AS value
  UNION ALL SELECT 2, 'books의 기본키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY k.ord)
            FROM pg_constraint c,
                 unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord),
                 pg_attribute a
           WHERE c.conrelid = 'books'::regclass AND c.contype = 'p'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 3, 'orders의 기본키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY k.ord)
            FROM pg_constraint c,
                 unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord),
                 pg_attribute a
           WHERE c.conrelid = 'orders'::regclass AND c.contype = 'p'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 4, 'order_items의 기본키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY k.ord)
            FROM pg_constraint c,
                 unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord),
                 pg_attribute a
           WHERE c.conrelid = 'order_items'::regclass AND c.contype = 'p'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 5, 'reviews의 기본키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY k.ord)
            FROM pg_constraint c,
                 unnest(c.conkey) WITH ORDINALITY AS k(attnum, ord),
                 pg_attribute a
           WHERE c.conrelid = 'reviews'::regclass AND c.contype = 'p'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 6, 'orders의 외래키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY a.attname)
            FROM pg_constraint c, unnest(c.conkey) AS k(attnum), pg_attribute a
           WHERE c.conrelid = 'orders'::regclass AND c.contype = 'f'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 7, 'order_items의 외래키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY a.attname)
            FROM pg_constraint c, unnest(c.conkey) AS k(attnum), pg_attribute a
           WHERE c.conrelid = 'order_items'::regclass AND c.contype = 'f'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 8, 'reviews의 외래키 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY a.attname)
            FROM pg_constraint c, unnest(c.conkey) AS k(attnum), pg_attribute a
           WHERE c.conrelid = 'reviews'::regclass AND c.contype = 'f'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum)
  UNION ALL SELECT 9, 'reviews의 외래키 중 널을 허용하는 열',
         (SELECT string_agg(a.attname, ', ' ORDER BY a.attname)
            FROM pg_constraint c, unnest(c.conkey) AS k(attnum), pg_attribute a
           WHERE c.conrelid = 'reviews'::regclass AND c.contype = 'f'
             AND a.attrelid = c.conrelid AND a.attnum = k.attnum
             AND NOT a.attnotnull)
  UNION ALL SELECT 10, 'books를 가리키는 테이블',
         (SELECT string_agg(DISTINCT c.conrelid::regclass::text, ', ')
            FROM pg_constraint c
           WHERE c.confrelid = 'books'::regclass AND c.contype = 'f')
  UNION ALL SELECT 11, 'customers를 가리키는 테이블',
         (SELECT string_agg(DISTINCT c.conrelid::regclass::text, ', ')
            FROM pg_constraint c
           WHERE c.confrelid = 'customers'::regclass AND c.contype = 'f')
  UNION ALL SELECT 12, 'orders를 가리키는 테이블',
         (SELECT string_agg(DISTINCT c.conrelid::regclass::text, ', ')
            FROM pg_constraint c
           WHERE c.confrelid = 'orders'::regclass AND c.contype = 'f')
) AS t
ORDER BY t.ord;
