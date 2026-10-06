# exercise 3 해설의 모범답안 — 네 함수로 나눈 work/ex3.py 입니다 (지문의 화면과 같은 출력).
def read_rows(records):
    rows = []
    for line in records:
        rows.append(line.split("|"))
    return rows


def pick_warm(rows, limit=10):
    warm = []
    for cells in rows:
        if float(cells[3]) >= limit:
            warm.append(cells)
    return warm


def average_high(rows):
    highs = []
    for cells in rows:
        highs.append(float(cells[3]))
    return sum(highs) / len(highs)


def print_warm(rows, average):
    dates = []
    for cells in rows:
        dates.append(cells[1])
    print("따뜻한 날:", ", ".join(dates))
    print(f"평균 최고기온: {average:.1f}도")


nm_records = [
    "NM|2025-11-01|2.6|7.6|0.0|구름많음",
    "NM|2025-11-02|1.6|10.8|0.0|흐림",
    "NM|2025-11-03|2.4|7.4|0.0|흐림",
    "NM|2025-11-04|3.7|9.8|8.5|비",
    "NM|2025-11-05|3.3|12.0|1.0|비",
    "NM|2025-11-06|-0.5|7.1|0.0|구름많음",
    "NM|2025-11-07|2.6|9.8|0.0|흐림",
    "NM|2025-11-08|2.5|10.7|0.0|흐림",
    "NM|2025-11-09|1.0|8.3|0.0|구름많음",
    "NM|2025-11-10|-0.5|7.5|0.0|맑음",
]
warm = pick_warm(read_rows(nm_records))
print_warm(warm, average_high(warm))
