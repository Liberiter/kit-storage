-- 동료가 쓴 검토 대상 2 — 쿠폰 기능 스키마
-- 작성: 개발팀 홍다은 매니저 / 검토 요청: "이번 분기 쿠폰 기능의 테이블입니다. 바로 배포하려고 합니다."
-- 실행: 스키마 peer 에 테이블을 만들고 예시 데이터를 넣는다 (./reset.sh 가 지운다).

CREATE SCHEMA IF NOT EXISTS peer;

CREATE TABLE peer.coupons (
    code        varchar(20),
    name        text,
    discount    real,              -- 'rate' 면 할인율(0.1 = 10%), 'amount' 면 할인 금액(원)
    kind        text,              -- 'rate' 또는 'amount'
    valid_until timestamp,
    used_count  integer DEFAULT 0  -- 지금까지 쓰인 횟수 (쿠폰을 쓸 때마다 1 올린다)
);

CREATE TABLE peer.coupon_redemptions (
    redemption_id serial PRIMARY KEY,
    coupon_code   varchar(20),
    coupon_name   text,            -- 화면에 바로 보여 주려고 함께 저장
    sale_id       bigint REFERENCES sales (sale_id),
    account_id    integer,         -- 누가 썼는지 바로 보려고 함께 저장
    redeemed_at   timestamptz DEFAULT now()
);

INSERT INTO peer.coupons (code, name, discount, kind, valid_until) VALUES
  ('WELCOME26', '2026 신규 가입 환영', 0.1,  'rate',   '2026-12-31 23:59:59'),
  ('SPRING26',  '봄맞이 할인',          2000, 'amount', '2026-05-31 23:59:59'),
  ('BOOKDAY26', '책의 날',              0.15, 'rate',   '2026-04-23 23:59:59'),
  ('BOOKDAY26', '책의 날 (재발급)',     0.15, 'rate',   '2026-04-30 23:59:59');

-- 쿠폰을 쓴 판매를 옮겨 담는다 (2026년 판매 가운데 쿠폰 코드가 있는 것)
INSERT INTO peer.coupon_redemptions (coupon_code, coupon_name, sale_id, account_id, redeemed_at)
SELECT s.coupon_code, c.name, s.sale_id, s.account_id, s.sold_at
  FROM sales s
  JOIN peer.coupons c ON c.code = s.coupon_code
 WHERE s.sold_at >= '2026-01-01';

UPDATE peer.coupons c
   SET used_count = (SELECT count(*) FROM peer.coupon_redemptions r WHERE r.coupon_code = c.code);
