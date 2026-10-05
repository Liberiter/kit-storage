-- scale_schema.sql — 책숲의 대규모 운영 데이터를 담는 테이블 정의.
--
-- 앞 코스(intermediate)의 책숲 운영 world(schema.sql 의 열두 테이블과 legacy·antipatterns
-- 두 스키마)는 그대로 두고, 그 곁에 아래 테이블을 더한다. 데이터는 seed_scale.sql 이
-- 적재할 때 결정적으로 만들고, 인덱스와 외래키는 적재가 끝난 뒤 seed_scale.sql 끝에서
-- 건다 (빈 테이블에 인덱스를 먼저 걸면 적재가 몇 배 느려진다).
--
--   stores            지점 12곳 (온라인몰 1 + 오프라인 매장 11)
--   accounts           회원 30만 명. 앞 코스의 고객 150명은 accounts.customer_id 로 이어진다
--   sales             판매 기록 150만 건 (판매 한 줄 = 책 한 종). 시각 차례로 적재했다
--   shipments_sorted  온라인 판매의 배송 기록 — 발송 시각 차례로 적재
--   shipments_random  같은 배송 기록을 해시 차례(사실상 무작위)로 적재 — 행은 위와 같다
--   book_contents     책마다 소개·발췌·목차 — 값의 크기가 수십 바이트에서 수십 KB까지
--   discussion_posts  독서 토론 게시판 — 댓글이 댓글을 다는 깊은 계층
--   duty_roster       지점별 당직표 (작은 테이블 — 두 세션 실습 재료)
--
-- 일부러 두지 않은 인덱스가 있다: sales 의 외래키 열(account_id·book_id·store_id)과
-- sold_at, accounts 의 city·district·grade, discussion_posts.parent_id. 인덱스를 언제 어떻게
-- 만들지가 이 코스의 실습 거리다.

CREATE TABLE stores (
    store_id  smallint PRIMARY KEY,
    name      text     NOT NULL UNIQUE,
    kind      text     NOT NULL CHECK (kind IN ('online', 'offline')),
    city      text,                        -- 온라인몰은 NULL
    opened_on date     NOT NULL,
    CHECK ((kind = 'online') = (city IS NULL))
);

CREATE TABLE accounts (
    account_id        integer     PRIMARY KEY,
    email            text        NOT NULL UNIQUE,   -- 가입 때 적은 그대로 (대소문자 섞임)
    name             text        NOT NULL,
    city             text        NOT NULL,
    district         text        NOT NULL,          -- 구·시·동 — 이름만 보면 city 가 정해진다
    birth_year       smallint    NOT NULL CHECK (birth_year BETWEEN 1940 AND 2012),
    grade            text        NOT NULL CHECK (grade IN ('일반', '실버', '골드', 'VIP')),
    joined_at        timestamptz NOT NULL,
    marketing_opt_in boolean     NOT NULL,
    customer_id      integer     UNIQUE              -- 앞 코스 고객이면 그 번호 (외래키는 적재 뒤에)
);

CREATE TABLE sales (
    sale_id     bigint      PRIMARY KEY,
    sold_at     timestamptz NOT NULL,
    account_id   integer     NOT NULL,
    book_id     integer     NOT NULL,
    store_id    smallint    NOT NULL,
    channel     text        NOT NULL CHECK (channel IN ('web', 'app', 'store')),
    quantity    smallint    NOT NULL CHECK (quantity > 0),
    unit_price  integer     NOT NULL CHECK (unit_price > 0),
    status      text        NOT NULL CHECK (status IN ('completed', 'refunded', 'disputed')),
    coupon_code text,                                -- 쿠폰을 쓴 판매만
    receipt_no  text        NOT NULL
);

CREATE TABLE shipments_sorted (
    shipment_id integer     PRIMARY KEY,
    sale_id     bigint      NOT NULL,
    shipped_at  timestamptz NOT NULL,
    carrier     text        NOT NULL,
    region      text        NOT NULL,
    weight_g    integer     NOT NULL CHECK (weight_g > 0)
);

CREATE TABLE shipments_random (LIKE shipments_sorted INCLUDING ALL);

CREATE TABLE book_contents (
    book_id  integer PRIMARY KEY,
    summary  text    NOT NULL,          -- 수십~수백 바이트
    excerpt  text    NOT NULL,          -- 수백 바이트 ~ 수십 KB
    toc      jsonb   NOT NULL           -- 목차 (장 수가 책마다 다르다)
);

CREATE TABLE discussion_posts (
    post_id   integer     PRIMARY KEY,
    parent_id integer,                  -- 글타래의 첫 글은 NULL
    book_id   integer     NOT NULL,
    account_id integer     NOT NULL,
    posted_at timestamptz NOT NULL,
    body      text        NOT NULL
);

CREATE TABLE duty_roster (
    store_id smallint NOT NULL,
    staff_id integer  NOT NULL,
    on_duty  boolean  NOT NULL,
    PRIMARY KEY (store_id, staff_id)
);
