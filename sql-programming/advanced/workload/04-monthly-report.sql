-- 워크로드 4 — 월별 지점 매출 보고서: 올해(2026년) 판매를 달·지점별로 모은다 (2번).
SELECT to_char(sold_at AT TIME ZONE 'Asia/Seoul', 'YYYY-MM') AS month, store_id,
       sum(quantity * unit_price) AS revenue
  FROM sales
 WHERE to_char(sold_at AT TIME ZONE 'Asia/Seoul', 'YYYY') = '2026'
 GROUP BY 1, 2
 ORDER BY 1, 2;
SELECT to_char(sold_at AT TIME ZONE 'Asia/Seoul', 'YYYY-MM') AS month, store_id,
       sum(quantity * unit_price) AS revenue
  FROM sales
 WHERE to_char(sold_at AT TIME ZONE 'Asia/Seoul', 'YYYY') = '2026'
 GROUP BY 1, 2
 ORDER BY 1, 2;
