-- 5장 «도전하기» problem 2 해설: 창 안에 창을 넣으면 오류 (오류 기대)
SELECT
    movement_id AS 원장번호,
    quantity AS 수량,
    sum(quantity) OVER (ORDER BY moved_at, movement_id) AS 누적잔량,
    lag(sum(quantity) OVER (ORDER BY moved_at, movement_id)) OVER (
        ORDER BY moved_at, movement_id
    ) AS 직전잔량
FROM stock_movements
WHERE book_id = 47
ORDER BY moved_at, movement_id;
