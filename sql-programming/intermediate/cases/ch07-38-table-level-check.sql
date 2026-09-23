-- runner: reset
-- 7장 «연습하기» exercise 1 해설: 두 열을 함께 보는 표 수준 CHECK
ALTER TABLE supplier_feed
ADD CONSTRAINT supplier_feed_received_after_feed_date
CHECK (received_at >= feed_date);

\d supplier_feed
