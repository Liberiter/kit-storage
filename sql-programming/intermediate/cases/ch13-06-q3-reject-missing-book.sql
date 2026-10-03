-- runner: reset
-- 13장(exit assessment) 문항 3 (나) 해설의 위반 표: 책숲에 없는 책 (오류 기대)
CREATE TABLE talk_events (
    event_id integer PRIMARY KEY,
    title text NOT NULL,
    book_id integer NOT NULL REFERENCES books (book_id),
    event_date date NOT NULL,
    capacity integer NOT NULL CHECK (capacity > 0),
    fee integer NOT NULL CHECK (fee >= 0),
    UNIQUE (book_id, event_date)
);

CREATE TABLE talk_bookings (
    event_id integer NOT NULL REFERENCES talk_events (event_id),
    customer_id integer NOT NULL REFERENCES customers (customer_id),
    booked_on date NOT NULL,
    seats integer NOT NULL CHECK (seats BETWEEN 1 AND 4),
    PRIMARY KEY (event_id, customer_id)
);

INSERT INTO talk_events (event_id, title, book_id, event_date, capacity, fee)
VALUES
    (1, '조용한 그림자 사전 낭독회', 42, '2026-10-17', 30, 0),
    (2, '도보 여행 작가와의 대화', 97, '2026-10-24', 20, 5000),
    (3, '계절 에세이 함께 쓰기', 150, '2026-11-07', 12, 10000);

INSERT INTO talk_bookings (event_id, customer_id, booked_on, seats)
VALUES
    (1, 3, '2026-09-28', 2),
    (1, 8, '2026-10-01', 1),
    (2, 3, '2026-10-02', 4);

INSERT INTO talk_events (event_id, title, book_id, event_date, capacity, fee)
VALUES (4, '없는 책으로 여는 행사', 999, '2026-11-14', 10, 0);
