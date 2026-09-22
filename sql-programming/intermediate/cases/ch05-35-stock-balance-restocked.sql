-- 5장 5.3 «practice» 2: 다른 책의 재고 원장 누적 잔량
SELECT
    movement_id AS 원장번호,
    CAST(moved_at AS date) AS 날짜,
    reason AS 사유,
    quantity AS 수량,
    sum(quantity) OVER (ORDER BY moved_at, movement_id) AS 누적잔량
FROM stock_movements
WHERE book_id = 124
ORDER BY moved_at, movement_id;
