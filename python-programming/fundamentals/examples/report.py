"""바람재 관측소의 열흘치 기록을 읽어 한 줄로 보고합니다."""

records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "BJ|2025-11-06|-1.7|7.6|0.0|구름많음",
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
]

# 1단계 — 읽기: 줄을 칸으로 나눕니다.
split_rows = []
for line in records:
    split_rows.append(line.split("|"))

# 2단계 — 고르기: 비가 온 날만 남깁니다.
rainy = []
for cells in split_rows:
    if float(cells[4]) > 0:
        rainy.append(cells)

# 3단계 — 계산: 강수량을 더합니다.
added = 0.0
for cells in rainy:
    added = added + float(cells[4])

# 4단계 — 보고: 한 줄로 알립니다.
print("관측소:", split_rows[0][0])
print("읽은 날수:", len(split_rows))
print("비 온 날수:", len(rainy))
print("강수량 합계:", round(added, 1))
