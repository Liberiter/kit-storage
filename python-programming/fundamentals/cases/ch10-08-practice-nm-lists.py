# 10.1절 practice 1 풀이 — 너미 기록으로 두 리스트를 내포로 만드는 work/nm_lists.py 의 화면입니다.
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
rows = [line.split("|") for line in nm_records]
highs = [float(cells[3]) for cells in rows]
freezing = [cells[1] for cells in rows if float(cells[2]) < 0]
print(highs)
print(freezing)
