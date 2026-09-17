-- 1장 1.2 «따라 하기» 5단계: 단순 형태의 CASE 를 정렬 키로 쓴다
SELECT status AS 상태, count(*) AS 주문수
FROM orders
GROUP BY status
ORDER BY
    CASE status
        WHEN '배송준비' THEN 1
        WHEN '배송중' THEN 2
        WHEN '배송완료' THEN 3
        ELSE 4
    END;
