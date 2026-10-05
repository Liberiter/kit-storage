-- 동료가 쓴 검토 대상 5 — 판매 요약 테이블 (비정규화 제안)
-- 작성: 개발팀 최민서 팀장 / 검토 요청: "분야별 베스트셀러 위젯이 1초씩 걸립니다. 책마다 판매 수를 따로 들고
-- 있으면 바로 읽을 수 있습니다. 판매가 들어올 때마다 트리거가 맞춰 줍니다."
-- 실행: 스키마 peer 에 요약 테이블과 트리거를 만든다 (sales 에 트리거가 걸린다. ./reset.sh 가 지운다).

CREATE SCHEMA IF NOT EXISTS peer;

CREATE TABLE peer.book_sales_summary (
    book_id       integer PRIMARY KEY REFERENCES books (book_id),
    sold_count    bigint      NOT NULL,
    sold_quantity bigint      NOT NULL,
    updated_at    timestamptz NOT NULL
);

INSERT INTO peer.book_sales_summary (book_id, sold_count, sold_quantity, updated_at)
SELECT book_id, count(*), sum(quantity), now()
  FROM sales
 GROUP BY book_id;

CREATE FUNCTION peer.bump_book_sales() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE peer.book_sales_summary
     SET sold_count    = sold_count + 1,
         sold_quantity = sold_quantity + NEW.quantity,
         updated_at    = now()
   WHERE book_id = NEW.book_id;
  RETURN NEW;
END $$;

CREATE TRIGGER sales_bump_summary
  AFTER INSERT ON sales
  FOR EACH ROW EXECUTE FUNCTION peer.bump_book_sales();

-- 바뀐 위젯 질의
SELECT b.title, s.sold_count AS sold
  FROM books b
  JOIN peer.book_sales_summary s USING (book_id)
 WHERE b.category = '과학'
 ORDER BY sold DESC, b.title
 LIMIT 5;
