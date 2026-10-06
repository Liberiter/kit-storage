# problem 2 해설 — 모범답안 work/ranges.py 의 화면입니다.
def daily_ranges(lines, code):
    rows = [line.split("|") for line in lines]
    return [
        round(float(cells[3]) - float(cells[2]), 1)
        for cells in rows
        if cells[0] == code
    ]


records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "NM|2025-11-01|2.6|7.6|0.0|구름많음",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "NM|2025-11-02|1.6|10.8|0.0|흐림",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "NM|2025-11-03|2.4|7.4|0.0|흐림",
]
for code in ["BJ", "NM"]:
    ranges = daily_ranges(records, code)
    print(code, ranges, max(ranges))
