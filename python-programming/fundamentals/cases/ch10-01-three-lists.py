# 10.1절 «문제 상황» — 반복문 셋으로 리스트를 하나씩 쌓는 work/three_lists.py 의 화면입니다.
records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
]
rows = []
for line in records:
    rows.append(line.split("|"))
lows = []
for cells in rows:
    lows.append(float(cells[2]))
highs = []
for cells in rows:
    highs.append(float(cells[3]))
print(lows)
print(highs)
