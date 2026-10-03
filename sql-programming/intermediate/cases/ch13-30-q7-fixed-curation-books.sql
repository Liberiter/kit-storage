-- runner: reset
-- 13장(exit assessment) 문항 7 해설: 교차 테이블로 교정 — 옮기고, 옮긴 수를 대조하고, 같은 질문을 다시 던지고, 없는 책이 막히는지 (마지막 문장은 오류 기대)
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

CREATE TABLE curation_books (
    curation_id integer NOT NULL REFERENCES curations (curation_id),
    book_id integer NOT NULL REFERENCES books (book_id),
    PRIMARY KEY (curation_id, book_id)
);

INSERT INTO curation_books (curation_id, book_id)
SELECT curations.curation_id, books.book_id
FROM curations
INNER JOIN books
    ON ',' || curations.book_ids || ','
        LIKE '%,' || CAST(books.book_id AS text) || ',%';

SELECT
    curations.curation_id AS 번호,
    curations.book_ids AS 옛목록,
    count(curation_books.book_id) AS 옮긴책수
FROM curations
LEFT JOIN curation_books ON curations.curation_id = curation_books.curation_id
GROUP BY curations.curation_id, curations.book_ids
ORDER BY 번호;

SELECT curations.curation_id AS 번호, curations.title AS 큐레이션
FROM curations
INNER JOIN curation_books ON curations.curation_id = curation_books.curation_id
WHERE curation_books.book_id = 42
ORDER BY 번호;

INSERT INTO curation_books (curation_id, book_id) VALUES (5, 420);
