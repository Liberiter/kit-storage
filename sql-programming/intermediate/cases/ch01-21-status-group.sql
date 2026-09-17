-- 1장 1.2 «practice» 1: 상태 네 가지를 세 묶음으로 갈라 센다
SELECT
    CASE
        WHEN status IN ('배송준비', '배송중') THEN '진행 중'
        WHEN status = '배송완료' THEN '끝남'
        ELSE '취소'
    END AS 구분,
    count(*) AS 주문수
FROM orders
GROUP BY
    CASE
        WHEN status IN ('배송준비', '배송중') THEN '진행 중'
        WHEN status = '배송완료' THEN '끝남'
        ELSE '취소'
    END
ORDER BY 주문수 DESC;
