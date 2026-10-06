# 10.1절 «예측해 보기»·«따라 하기» 1단계 — 리스트 내포로 적은 work/comp_first.py 의 화면입니다.
records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
]
rows = [line.split("|") for line in records]
lows = [float(cells[2]) for cells in rows]
rainy_dates = [cells[1] for cells in rows if float(cells[4]) > 0]
print(lows)
print(rainy_dates)
print(len(rows), rows[0][1])
