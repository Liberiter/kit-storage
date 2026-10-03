-- runner: reset
-- 13장(exit assessment) 문항 3 (나) 해설: 모범 DDL + 검증 ①(정상 행 넣기와 확인 질의)
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

SELECT
    talk_events.event_id AS 행사번호,
    talk_events.title AS 행사,
    talk_events.capacity AS 정원,
    count(talk_bookings.customer_id) AS 예약건수,
    COALESCE(sum(talk_bookings.seats), 0) AS 예약인원
FROM talk_events
LEFT JOIN talk_bookings ON talk_events.event_id = talk_bookings.event_id
GROUP BY talk_events.event_id, talk_events.title, talk_events.capacity
ORDER BY talk_events.event_id;
