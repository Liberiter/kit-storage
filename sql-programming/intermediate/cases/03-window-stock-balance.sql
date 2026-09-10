-- smoke: 윈도우 함수 — 1번 책 재고 원장의 누적 잔량과 직전 이벤트 (5장 요구 예시)
SELECT movement_id,
       moved_at AT TIME ZONE 'Asia/Seoul' AS moved_kst,
       reason,
       quantity,
       sum(quantity) OVER (ORDER BY moved_at, movement_id) AS balance,
       lag(moved_at, 1) OVER (ORDER BY moved_at, movement_id) AT TIME ZONE 'Asia/Seoul' AS prev_kst
FROM stock_movements
WHERE book_id = 1
ORDER BY moved_at, movement_id;
