-- 입장 점검 문항 2 의 확인 질의 — entry_check.sh 가 여러분의 DDL 을 실행한 뒤 이것을 돌려 기대 결과
-- (entry/expected/q2.expected)와 대조한다. 여러분이 고칠 파일이 아니다.
-- 행을 하나씩 넣어 보고 받아들였는지(ok), 거절했다면 어떤 종류의 위반인지(SQLSTATE)를 적는다.
CREATE FUNCTION pg_temp.try_insert(sql text) RETURNS text LANGUAGE plpgsql AS $f$
BEGIN
  EXECUTE sql;
  RETURN 'ok';
EXCEPTION WHEN OTHERS THEN
  RETURN 'rejected ' || SQLSTATE;
END $f$;

SELECT t.no, t.case_name, pg_temp.try_insert(t.sql) AS result
  FROM (VALUES
    (1, '정상 - 반납 전',             $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on) VALUES (1, 1, '2026-09-01', '2026-09-15')$$),
    (2, '정상 - 반납함',              $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on, returned_on) VALUES (2, 1, '2026-09-01', '2026-09-15', '2026-09-10')$$),
    (3, '정상 - 같은 날 반납',        $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on, returned_on) VALUES (3, 2, '2026-09-02', '2026-09-03', '2026-09-02')$$),
    (4, '없는 책',                    $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on) VALUES (99999, 1, '2026-09-01', '2026-09-15')$$),
    (5, '없는 회원',                  $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on) VALUES (1, 999999, '2026-09-01', '2026-09-15')$$),
    (6, '반납 예정일이 빌린 날',      $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on) VALUES (4, 3, '2026-09-01', '2026-09-01')$$),
    (7, '반납일이 빌린 날보다 앞',    $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on, returned_on) VALUES (5, 3, '2026-09-05', '2026-09-20', '2026-09-04')$$),
    (8, '같은 회원 같은 책 같은 날',  $$INSERT INTO book_loans (book_id, account_id, loaned_on, due_on) VALUES (1, 1, '2026-09-01', '2026-09-30')$$),
    (9, '빌린 날 없음',               $$INSERT INTO book_loans (book_id, account_id, due_on) VALUES (6, 4, '2026-09-30')$$),
    (10, '책 없음',                   $$INSERT INTO book_loans (account_id, loaned_on, due_on) VALUES (4, '2026-09-01', '2026-09-30')$$),
    (11, '회원 없음',                 $$INSERT INTO book_loans (book_id, loaned_on, due_on) VALUES (6, '2026-09-01', '2026-09-30')$$),
    (12, '반납 예정일 없음',          $$INSERT INTO book_loans (book_id, account_id, loaned_on) VALUES (7, 5, '2026-09-01')$$)
  ) AS t(no, case_name, sql)
 ORDER BY t.no;

SELECT count(*) AS rows_kept, count(DISTINCT loan_id) AS distinct_loan_ids FROM book_loans;
