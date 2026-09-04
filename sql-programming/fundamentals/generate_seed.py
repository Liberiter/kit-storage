#!/usr/bin/env python3
"""seed.sql 생성기 — 결정적(고정 시드) 생성. 결과물 seed.sql은 커밋한다.

curriculum §1·§5의 world 요구를 데이터 분포로 보장한다:
- 자식 없는 부모(주문 없는 고객, 주문·리뷰 없는 책), NULL 분포,
  중복 값·동점 정렬 값, 그룹 크기 편차, LIKE 대상 패턴 등.
재생성: python3 generate_seed.py > seed.sql
"""
import random
from datetime import date, timedelta

rng = random.Random(20260824)  # 고정 시드 — 재현성

TODAY = date(2026, 8, 24)     # 생성 기준일 고정 (재현성)

# ---------- 이름 ----------
FAMILY = [("김", "kim"), ("이", "lee"), ("박", "park"), ("최", "choi"),
          ("정", "jung"), ("강", "kang"), ("조", "cho"), ("윤", "yoon"),
          ("장", "jang"), ("임", "lim"), ("한", "han"), ("오", "oh"),
          ("서", "seo"), ("신", "shin"), ("권", "kwon")]
GIVEN = [("민준", "minjun"), ("서연", "seoyeon"), ("지우", "jiwoo"),
         ("하윤", "hayun"), ("도윤", "doyun"), ("은우", "eunwoo"),
         ("수아", "sua"), ("예준", "yejun"), ("시우", "siwoo"),
         ("지아", "jia"), ("주원", "juwon"), ("아린", "arin"),
         ("현우", "hyunwoo"), ("소율", "soyul"), ("건우", "gunwoo"),
         ("다은", "daeun"), ("연우", "yeonwoo"), ("유나", "yuna"),
         ("승현", "seunghyun"), ("채원", "chaewon")]
CITIES = ["서울", "부산", "대구", "인천", "광주", "대전", "울산", "수원",
          "제주", "춘천"]

# ---------- 도서 ----------
CATEGORIES = ["소설", "에세이", "과학", "역사", "자기계발", "요리", "여행", "어린이"]
PREFIX = ["처음 만나는", "한 권으로 읽는", "오늘의", "어느 날의", "우리가 몰랐던",
          "밤에 읽는", "다시 쓰는", "작은", "조용한", "빛나는"]
SUBJECT = {
    "소설": ["바다", "정원", "겨울 편지", "골목", "등대", "약속", "그림자", "여름밤"],
    "에세이": ["산책", "부엌", "계절", "혼자의 시간", "골목길", "서재", "아침"],
    "과학": ["우주", "세포", "별자리", "진화", "숫자", "날씨", "뇌", "바이러스"],
    "역사": ["고려", "조선", "실크로드", "혁명", "항해", "제국", "유적"],
    "자기계발": ["습관", "말하기", "몰입", "기록", "질문", "루틴", "협상"],
    "요리": ["국수", "빵", "김치", "채소", "커피", "한 그릇", "도시락"],
    "여행": ["제주 여행", "기차 여행", "골목 여행", "섬 여행", "도보 여행",
             "유럽 여행", "새벽 여행"],
    "어린이": ["공룡", "로봇", "숲속 친구들", "바다 탐험", "별나라", "꼬마 화가"],
}
SUFFIX = ["이야기", "수업", "노트", "사전", "기록", "안내서", "연습", ""]

def esc(s):
    return s.replace("'", "''")

def d(day):
    return f"'{day.isoformat()}'"

def rand_date(a, b):
    return a + timedelta(days=rng.randrange((b - a).days + 1))

out = []
out.append("-- seed.sql — generate_seed.py(시드 20260824)로 생성. 직접 수정하지 말 것.")
out.append("BEGIN;")

# ---------- customers (150명; 마지막 18명은 주문 없음) ----------
N_CUST = 150
emails = set()
customers = []
for i in range(1, N_CUST + 1):
    fam = rng.choice(FAMILY); giv = rng.choice(GIVEN)
    name = fam[0] + giv[0]
    base = f"{giv[1]}.{fam[1]}"
    email = f"{base}@bookmail.kr"
    k = 1
    while email in emails:
        k += 1
        email = f"{base}{k}@bookmail.kr"
    emails.add(email)
    city = rng.choice(CITIES)
    signup = rand_date(date(2022, 1, 2), date(2026, 8, 10))
    opt_in = rng.random() < 0.55
    birth = "NULL"
    if rng.random() < 0.7:  # 30%는 미입력 (NULL)
        birth = d(rand_date(date(1962, 1, 1), date(2008, 12, 31)))
    customers.append((i, name, email, city, signup, opt_in, birth))

out.append("INSERT INTO customers (customer_id, name, email, city, signup_date, marketing_opt_in, birth_date) VALUES")
rows = [f"({c[0]}, '{esc(c[1])}', '{c[2]}', '{c[3]}', {d(c[4])}, {str(c[5]).lower()}, {c[6]})"
        for c in customers]
out.append(",\n".join(rows) + ";")

# ---------- books (320권; 가격 500원 단위 → 동점 보장) ----------
N_BOOK = 320
books = []
titles = set()
for i in range(1, N_BOOK + 1):
    cat = rng.choice(CATEGORIES)
    for _ in range(50):
        t = f"{rng.choice(PREFIX)} {rng.choice(SUBJECT[cat])}"
        suf = rng.choice(SUFFIX)
        if suf:
            t = f"{t} {suf}"
        if t not in titles:
            titles.add(t)
            break
    fam = rng.choice(FAMILY); giv = rng.choice(GIVEN)
    author = fam[0] + giv[0]
    price = rng.randrange(8000, 42001, 500)
    pages = rng.randrange(120, 761, 4)
    pub = rand_date(date(1998, 1, 1), date(2026, 7, 31))
    stock = rng.choice([0, 1, 2, 3, 5, 8, 12, 20, 35, 60])
    books.append((i, t, author, cat, price, pages, pub, stock))

out.append("INSERT INTO books (book_id, title, author, category, price, page_count, published_date, stock) VALUES")
rows = [f"({b[0]}, '{esc(b[1])}', '{esc(b[2])}', '{b[3]}', {b[4]}, {b[5]}, {d(b[6])}, {b[7]})"
        for b in books]
out.append(",\n".join(rows) + ";")

# ---------- orders (620건) + order_items ----------
# 고객별 주문 수 편차: 마지막 18명 0건, 일부 헤비 유저 10건+
N_ORD = 620
orderable = customers[:-18]           # 주문 없는 고객 18명 확보
heavy = [c for c in orderable if c[0] % 17 == 0]  # 헤비 유저
weights = []
for c in orderable:
    weights.append(10 if c in heavy else rng.choice([1, 1, 1, 2, 2, 3]))

orders = []
items = []
never_ordered = set(b[0] for b in books if b[0] % 23 == 0)  # 주문 없는 책 확보(13권)
order_id = 0
oship = {}  # order_id -> 발송일(date) 또는 None
for _ in range(N_ORD):
    order_id += 1
    cust = rng.choices(orderable, weights=weights, k=1)[0]
    odate = rand_date(max(date(2024, 1, 2), cust[4]), date(2026, 8, 20))
    r = rng.random()
    if r < 0.08:
        status, shipped = "취소", None
    elif r < 0.22:
        status, shipped = "배송준비", None
    elif r < 0.34:
        status = "배송중"
        shipped = odate + timedelta(days=rng.randrange(0, 3))
    else:
        status = "배송완료"
        shipped = odate + timedelta(days=rng.randrange(0, 5))
    orders.append((order_id, cust[0], odate, status, shipped))
    oship[order_id] = shipped
    # 시간 정합: 주문일 이전에 출간된 책만 담는다
    avail = [b for b in books
             if b[6] <= odate and b[0] not in never_ordered]
    n_items = rng.choice([1, 1, 1, 2, 2, 3, 4])
    picked = set()
    for _ in range(n_items):
        b = rng.choice(avail)
        if b[0] in picked:
            continue
        picked.add(b[0])
        qty = rng.choice([1, 1, 1, 1, 2, 2, 3])
        items.append((order_id, b[0], qty, b[4]))

out.append("INSERT INTO orders (order_id, customer_id, order_date, status, shipped_date) VALUES")
rows = [f"({o[0]}, {o[1]}, {d(o[2])}, '{o[3]}', {d(o[4]) if o[4] else 'NULL'})"
        for o in orders]
out.append(",\n".join(rows) + ";")

out.append("INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES")
rows = [f"({t[0]}, {t[1]}, {t[2]}, {t[3]})" for t in items]
out.append(",\n".join(rows) + ";")

# ---------- reviews (약 520건; 리뷰 없는 책 확보) ----------
# 1차: 구매 인증 리뷰 (order_id 연결 — 주문에 실제 담긴 책만, world 정합)
# 2차: 일반 리뷰 (order_id NULL) — NULL 허용 FK 분포 확보 (7장 요구)
never_reviewed = set(b[0] for b in books if b[0] % 19 == 3)  # 리뷰 없는 책(17권)
ocust_by_id = {o[0]: o[1] for o in orders}
ostatus_by_id = {o[0]: o[3] for o in orders}
pub_by_id = {b[0]: b[6] for b in books}
phrases = ["재미있게 읽었어요", "기대보다 아쉬웠어요", "선물용으로 좋아요",
           "두고두고 읽을 책이에요", "설명이 친절해요", "배송이 빨랐어요",
           "표지가 예뻐요", "다음 권이 기다려져요"]

def mk_comment():
    if rng.random() < 0.35:   # 35%는 별점만 (comment NULL)
        return "NULL"
    return f"'{esc(rng.choice(phrases))}'"

review_id = 0
seen = set()
reviews = []
# 구매 인증 리뷰는 배송완료 주문에서만, 발송일 이후에 작성된다 (시간 정합)
verified_pool = [(it[0], it[1]) for it in items
                 if ostatus_by_id[it[0]] == '배송완료']
rng.shuffle(verified_pool)
for oid, bid in verified_pool:
    if review_id >= 300:
        break
    cid = ocust_by_id[oid]
    if bid in never_reviewed or (bid, cid) in seen or rng.random() < 0.5:
        continue
    seen.add((bid, cid))
    review_id += 1
    rating = rng.choices([1, 2, 3, 4, 5], weights=[1, 2, 4, 6, 5], k=1)[0]
    rdate = rand_date(oship[oid], TODAY)
    reviews.append((review_id, bid, cid, str(oid), rating, mk_comment(), rdate))

while review_id < 520:
    b = rng.choice(books)
    c = rng.choice(customers)
    if b[0] in never_reviewed or (b[0], c[0]) in seen:
        continue
    # 시간 정합: 가입일·출간일 이후에만 리뷰 가능
    earliest = max(date(2024, 1, 5), c[4], b[6])
    if earliest > TODAY:
        continue
    seen.add((b[0], c[0]))
    review_id += 1
    rating = rng.choices([1, 2, 3, 4, 5], weights=[1, 2, 4, 6, 5], k=1)[0]
    rdate = rand_date(earliest, TODAY)
    reviews.append((review_id, b[0], c[0], "NULL", rating, mk_comment(), rdate))

reviews.sort(key=lambda r: r[0])
out.append("INSERT INTO reviews (review_id, book_id, customer_id, order_id, rating, comment, review_date) VALUES")
rows = [f"({r[0]}, {r[1]}, {r[2]}, {r[3]}, {r[4]}, {r[5]}, {d(r[6])})" for r in reviews]
out.append(",\n".join(rows) + ";")

# identity 시퀀스 보정 (이후 INSERT가 자동 번호를 이어가도록 — 11장)
out.append("SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), (SELECT max(customer_id) FROM customers));")
out.append("SELECT setval(pg_get_serial_sequence('books', 'book_id'), (SELECT max(book_id) FROM books));")
out.append("SELECT setval(pg_get_serial_sequence('orders', 'order_id'), (SELECT max(order_id) FROM orders));")
out.append("SELECT setval(pg_get_serial_sequence('reviews', 'review_id'), (SELECT max(review_id) FROM reviews));")
out.append("COMMIT;")
out.append("ANALYZE;")

print("\n".join(out))
