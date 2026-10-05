-- 동료가 쓴 검토 대상 3 — 판매·회원 테이블 인덱스 제안
-- 작성: 개발팀 송건우 사원 / 검토 요청: "자주 쓰는 질의마다 인덱스를 하나씩 만들면 다 빨라질 것 같습니다."
-- 실행: 인덱스를 실제로 만든다 (판매 150만 건이라 몇 초 걸린다. ./reset.sh 가 지운다).
-- 아래 주석의 질의가 각 인덱스로 빨라지길 기대한 것이다.

-- 회원의 구매 내역:  WHERE account_id = ?  ORDER BY sold_at DESC LIMIT 20
CREATE INDEX sales_account_idx        ON sales (account_id);
CREATE INDEX sales_account_soldat_idx ON sales (account_id, sold_at);

-- 지점별 기간 매출:  WHERE store_id = ? AND sold_at >= ? AND sold_at < ?
CREATE INDEX sales_soldat_store_idx   ON sales (sold_at, store_id);

-- 앱 판매만 보기:  WHERE channel = 'app'
CREATE INDEX sales_channel_idx        ON sales (channel);

-- 분쟁 처리 대기열:  WHERE status = 'disputed' ORDER BY sold_at DESC LIMIT 50
CREATE INDEX sales_status_idx         ON sales (status);

-- 로그인:  WHERE lower(email) = lower(?)
CREATE INDEX accounts_email_idx       ON accounts (email);

-- 마케팅 수신 동의 회원:  WHERE marketing_opt_in
CREATE INDEX accounts_optin_idx       ON accounts (marketing_opt_in);

ANALYZE sales;
ANALYZE accounts;
