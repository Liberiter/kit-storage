-- antipatterns.sql — 안티패턴을 일부러 심은 스키마 조각 (스키마 antipatterns, 8장).
-- 책숲이 다른 서점을 인수하며 받아 온 시스템이라는 설정이다. 진단·교정 대상이며 본
-- world(public)와 분리되어 있다 — 마음껏 고치고 지워도 되고, ./reset.sh 가 다시 만든다.
--
-- 심은 것 (테이블 → 안티패턴):
--   products            쉼표로 이어 붙인 태그 목록(tags), 금액에 부동소수(price real),
--                       제약 없는 자유 텍스트 상태(status: 'active'·'Active'·'활성'이 섞임),
--                       기본 키 없음 (code 가 키 역할을 하지만 선언되지 않았고 중복도 있다)
--   product_attributes  속성을 행으로 세운 EAV(Entity-Attribute-Value) — 값이 전부 글자
--   members             바뀔 수 있는 값(이메일)을 기본 키로, 전화번호 칸 셋(phone1~3),
--                       날짜를 글자로(birth text)
--   comments            대상 종류 + 대상 번호로 여러 테이블을 가리키는 다형 연결
--                       (target_type·target_id — 외래키를 걸 수 없다)

SET client_min_messages = warning;

CREATE SCHEMA antipatterns;

CREATE TABLE antipatterns.products (
    code        text,            -- 기본 키로 선언되지 않았다
    name        text,
    tags        text,            -- '소설,베스트셀러,영화화' 식의 쉼표 목록
    price       real,            -- 금액에 부동소수
    status      text,            -- 제약 없는 자유 텍스트
    created_on  text             -- 날짜를 글자로, 형식도 제멋대로
);

INSERT INTO antipatterns.products VALUES
  ('BK-001', '밤에 읽는 우주 이야기',     '교양과학,우주,베스트셀러',   15999.99, 'active',   '2024-03-01'),
  ('BK-002', '처음 만나는 국수 수업',     '요리,홈쿡',                  12500,    'Active',   '2024/03/15'),
  ('BK-003', '어느 날의 산책 노트',       '에세이,일상,위로,선물추천',  13900,    '활성',     '24-04-02'),
  ('BK-004', '한 권으로 읽는 조선 기록',  '한국사,교양',                18000.5,  'active',   '2024-04-20'),
  ('BK-005', '작은 공룡 안내서',          '어린이,그림책',              9900,     'inactive', '2024-05-05'),
  ('BK-006', '조용한 겨울 편지',          '한국소설,장편',              14000,    'ACTIVE',   '2024-05-30'),
  ('BK-007', '오늘의 습관 연습',          '자기계발,습관,베스트셀러',   16500,    'active',   '2024-06-11'),
  ('BK-008', '빛나는 제주 여행 사전',     '여행,국내여행,사진많음',     19800,    'soldout',  '2024-07-01'),
  ('BK-008', '빛나는 제주 여행 사전 (개정)', '여행,국내여행',           21000,    'active',   '2025-02-01'),   -- code 중복
  ('BK-009', '우리가 몰랐던 세포 노트',   '교양과학,생명',              17000,    'active',   '2024-08-19'),
  ('BK-010', '다시 쓰는 실크로드 기록',   '세계사,교양,인물',           22000.1,  'active',   '2024-09-09'),
  ('BK-011', '꼬마 화가 이야기',          '어린이,그림책,선물추천',     11000,    'Active',   '2024-10-10'),
  ('BK-012', '기차 여행 연습',            '여행,에세이',                15500,    'inactive', '2024-11-11'),
  ('BK-013', '협상 수업',                 '자기계발,소통',              18500,    'active',   '2024-12-01'),
  ('BK-014', '빵 한 그릇',                '요리,베이킹,홈쿡',           14500,    '활성',     '2025-01-15'),
  ('BK-015', '별자리 사전',               '교양과학,우주,청소년추천',   16000,    'active',   '2025-03-03');

CREATE TABLE antipatterns.product_attributes (
    product_code text,
    attr_name    text,
    attr_value   text
);

INSERT INTO antipatterns.product_attributes VALUES
  ('BK-001', 'pages',     '312'),
  ('BK-001', 'published', '2023-11-20'),
  ('BK-001', 'isbn',      '979-11-00001-001-1'),
  ('BK-002', 'pages',     '208'),
  ('BK-002', 'published', '2024-01-09'),
  ('BK-002', 'cover',     'soft'),
  ('BK-003', 'pages',     '240'),
  ('BK-003', 'published', '2024.02.14'),
  ('BK-004', 'pages',     '456 p.'),
  ('BK-004', 'published', '2023-09-01'),
  ('BK-004', 'isbn',      '979-11-00004-004-4'),
  ('BK-005', 'pages',     '48'),
  ('BK-005', 'age',       '5+'),
  ('BK-006', 'pages',     '388'),
  ('BK-006', 'published', '2024-04-30'),
  ('BK-007', 'pages',     '264'),
  ('BK-007', 'audiobook', 'yes'),
  ('BK-008', 'pages',     '320'),
  ('BK-008', 'published', '2024-06-15'),
  ('BK-009', 'pages',     '296'),
  ('BK-010', 'pages',     '512'),
  ('BK-010', 'published', '2024-08-01'),
  ('BK-011', 'pages',     '40'),
  ('BK-011', 'age',       '4+'),
  ('BK-012', 'pages',     '220'),
  ('BK-013', 'pages',     '280'),
  ('BK-013', 'published', '2024-11-15'),
  ('BK-014', 'pages',     '176'),
  ('BK-015', 'pages',     '232'),
  ('BK-015', 'published', '2025-02-20');

CREATE TABLE antipatterns.members (
    email   text PRIMARY KEY,    -- 바뀔 수 있는 값이 기본 키
    name    text NOT NULL,
    phone1  text,
    phone2  text,
    phone3  text,
    birth   text                 -- 날짜를 글자로
);

INSERT INTO antipatterns.members VALUES
  ('minjun.kim@oldshop.kr',    '김민준', '010-1111-2222', NULL,            NULL,            '1990-05-02'),
  ('seoyeon.lee@oldshop.kr',   '이서연', '010-2222-3333', '02-555-1234',   NULL,            '1988.11.30'),
  ('jiwoo.park@oldshop.kr',    '박지우', '010-3333-4444', '010-3333-4445', '031-222-0000',  '19950721'),
  ('hayun.choi@oldshop.kr',    '최하윤', NULL,            NULL,            NULL,            NULL),
  ('doyun.jung@oldshop.kr',    '정도윤', '010-5555-6666', NULL,            NULL,            '2001-02-29'),
  ('eunwoo.kang@oldshop.kr',   '강은우', '010-6666-7777', '010-6666-7778', NULL,            '1979-08-15'),
  ('sua.cho@oldshop.kr',       '조수아', '010-7777-8888', NULL,            NULL,            '1993-12-01'),
  ('yejun.yoon@oldshop.kr',    '윤예준', '010-8888-9999', '010-8888-9990', '010-8888-9991', '1985-03-17');

CREATE TABLE antipatterns.comments (
    comment_id   integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    target_type  text    NOT NULL,   -- 'product' 또는 'member' — 가리키는 테이블이 행마다 다르다
    target_id    text    NOT NULL,   -- products.code 이거나 members.email (외래키를 걸 수 없다)
    author_email text    NOT NULL,
    body         text    NOT NULL,
    written_at   text    NOT NULL
);

INSERT INTO antipatterns.comments (target_type, target_id, author_email, body, written_at) VALUES
  ('product', 'BK-001', 'minjun.kim@oldshop.kr',  '별자리 설명이 좋아요',          '2024-03-20 21:10'),
  ('product', 'BK-002', 'seoyeon.lee@oldshop.kr', '사진이 많아서 따라 하기 쉬워요', '2024-04-01 09:30'),
  ('product', 'BK-008', 'jiwoo.park@oldshop.kr',  '개정판이 나온다는데 기다릴까요', '2025-01-10 14:05'),
  ('product', 'BK-099', 'sua.cho@oldshop.kr',     '이 책은 언제 들어오나요',        '2025-02-02 11:11'),   -- 없는 상품
  ('member',  'hayun.choi@oldshop.kr', 'doyun.jung@oldshop.kr', '추천 감사합니다',   '2024-06-12 18:45'),
  ('member',  'nobody@oldshop.kr',     'eunwoo.kang@oldshop.kr', '안녕하세요',       '2024-07-01 08:00'),   -- 없는 회원
  ('product', 'BK-007', 'yejun.yoon@oldshop.kr',  '오디오북도 있나요',              '2024-12-24 23:59');
