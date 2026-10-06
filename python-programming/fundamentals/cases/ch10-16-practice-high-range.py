# 10.2절 practice 1 풀이 — 이름을 바꾼 work/high.py 의 화면입니다.
def high_range(lines):
    highs = [float(line.split("|")[3]) for line in lines]
    return max(highs), min(highs)


nm_lines = [
    "NM|2025-11-01|2.6|7.6|0.0|구름많음",
    "NM|2025-11-02|1.6|10.8|0.0|흐림",
    "NM|2025-11-03|2.4|7.4|0.0|흐림",
    "NM|2025-11-04|3.7|9.8|8.5|비",
    "NM|2025-11-05|3.3|12.0|1.0|비",
]
highest, lowest = high_range(nm_lines)
print(highest, lowest)
