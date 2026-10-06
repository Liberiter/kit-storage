# exercise 3 지문 — 한 덩어리로 적힌 work/ex3.py 와 그 화면입니다.
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
warm_dates = []
warm_highs = []
for line in nm_records:
    cells = line.split("|")
    if float(cells[3]) >= 10:
        warm_dates.append(cells[1])
        warm_highs.append(float(cells[3]))
print("따뜻한 날:", ", ".join(warm_dates))
print(f"평균 최고기온: {sum(warm_highs) / len(warm_highs):.1f}도")
