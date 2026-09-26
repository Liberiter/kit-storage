-- 9장 9.3 «흔한 실수» 2: IN (배열 열)은 원소가 아니라 배열 통째와 견준다 — 글자를 배열로 읽으려다 막힌다
SELECT count(*) AS 책수 FROM book_meta WHERE '교양' IN (tags);
