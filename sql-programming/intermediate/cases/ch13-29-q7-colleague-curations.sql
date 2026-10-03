-- runner: reset
-- 13장(exit assessment) 문항 7 지문: 동료가 만든 큐레이션 테이블(쉼표 구분 목록)와 42번 책을 찾는 LIKE 질의
CREATE TABLE curations (
    curation_id integer PRIMARY KEY,
    title text NOT NULL,
    book_ids text NOT NULL
);

INSERT INTO curations (curation_id, title, book_ids)
VALUES
    (1, '가을밤에 읽는 소설', '42,8,27'),
    (2, '선물하기 좋은 책', '142,60,150'),
    (3, '그림자와 빛', '242,42'),
    (4, '여행 가방 속 한 권', '97,284,144'),
    (5, '처음 읽는 분께', '2,16,420'),
    (6, '올해의 추천', '42,97,150,60');

SELECT curation_id AS 번호, title AS 큐레이션, book_ids AS 책목록
FROM curations
WHERE book_ids LIKE '%42%'
ORDER BY 번호;
