-- 0장이 인용하는 수치: 0.4 구축 화면의 「public: 책숲 운영 world 12테이블」과
-- 0.4 끝의 「./reset.sh 가 되돌리는 세 스키마(public·legacy·antipatterns)」,
-- 0.4 의 「앞 코스의 다섯 테이블은 그대로 있고」.
SELECT 'public 스키마의 테이블 수' AS claim,
       (SELECT count(*) FROM pg_tables WHERE schemaname = 'public') AS value
UNION ALL
SELECT 'reset.sh 가 다시 만드는 스키마 중 실제로 있는 것의 수',
       (SELECT count(*) FROM pg_namespace
         WHERE nspname IN ('public', 'legacy', 'antipatterns'))
UNION ALL
SELECT '앞 코스의 핵심 다섯 테이블 중 public 에 있는 것의 수',
       (SELECT count(*) FROM pg_tables
         WHERE schemaname = 'public'
           AND tablename IN ('customers', 'books', 'orders',
                             'order_items', 'reviews'));
