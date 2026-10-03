-- 13장(exit assessment) 문항 9 해설: 공식 문서 7.2.4절의 ROLLUP으로 연도별·상태별 주문 수와 연도 합계·전체 합계
WITH order_year AS (
    SELECT to_char(order_date, 'YYYY') AS 연도, status AS 상태 FROM orders
)
SELECT
    COALESCE(연도, '전체') AS 주문연도,
    COALESCE(상태, '합계') AS 주문상태,
    count(*) AS 주문수
FROM order_year
GROUP BY ROLLUP (연도, 상태)
ORDER BY 연도, 상태;
