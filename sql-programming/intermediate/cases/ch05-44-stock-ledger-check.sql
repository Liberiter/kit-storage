-- 5장 «도전하기» problem 2 해설: 누적 잔량과 직전 잔량을 함께 본다
WITH ledger AS (
    SELECT
        movement_id AS 원장번호,
        CAST(moved_at AS date) AS 날짜,
        quantity AS 수량,
        sum(quantity) OVER (ORDER BY moved_at, movement_id) AS 누적잔량
    FROM stock_movements
    WHERE book_id = 47
)
SELECT
    원장번호,
    날짜,
    수량,
    누적잔량,
    lag(누적잔량) OVER (ORDER BY 원장번호) AS 직전잔량
FROM ledger
ORDER BY 원장번호;
