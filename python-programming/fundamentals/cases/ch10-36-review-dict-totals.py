# 복습 exercise 3 해설 — 모범답안 work/review3.py 의 화면입니다.
lines = [
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
]
rows = [line.split("|") for line in lines]
totals = {}
for cells in rows:
    totals[cells[0]] = totals.get(cells[0], 0.0) + float(cells[4])
print(totals)
