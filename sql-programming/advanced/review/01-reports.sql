-- 동료가 쓴 검토 대상 1 — 마케팅팀 요청 보고서 질의 묶음
-- 작성: 운영팀 오준서 매니저 / 검토 요청: "다음 주 월요일 회의 전에 봐 주세요. 결과는 다 나옵니다."
-- 실행: world 위에서 그대로 돌아간다 (읽기만 한다).

-- [보고서 1] 2026년 VIP 회원의 월별 매출
SELECT to_char(s.sold_at, 'YYYY-MM') AS month,
       sum(s.quantity * s.unit_price) AS revenue
  FROM sales s
  JOIN accounts a ON a.account_id = s.account_id
 WHERE a.grade = 'VIP'
   AND to_char(s.sold_at, 'YYYY') = '2026'
 GROUP BY 1
 ORDER BY 1;

-- [보고서 2] 과학 분야 책의 판매 수량과 평균 별점
SELECT b.title,
       sum(s.quantity) AS sold,
       round(avg(r.rating), 2) AS avg_rating
  FROM books b
  JOIN sales s ON s.book_id = b.book_id
  LEFT JOIN reviews r ON r.book_id = b.book_id
 WHERE b.category = '과학'
 GROUP BY b.title
 ORDER BY sold DESC;

-- [보고서 3] 지난달(2026년 8월)에 한 번도 사지 않은 회원 수 (재구매 유도 메일 대상)
--   다음 분기에는 기간을 올해 전체(2026-01-01부터)로 넓혀 같은 질의를 쓸 예정.
SELECT count(*)
  FROM accounts
 WHERE account_id NOT IN (SELECT account_id FROM sales WHERE sold_at >= '2026-08-01');

-- [화면 질의] 판매 내역 화면 — 한 쪽에 50건, 4,001쪽째
SELECT *
  FROM sales
 ORDER BY sold_at DESC
OFFSET 200000 LIMIT 50;
