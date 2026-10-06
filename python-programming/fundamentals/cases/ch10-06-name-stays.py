# 10.1절 «왜 그럴까요» — 내포의 반복 변수와 for 문의 반복 변수를 견주는 work/name_stays.py 의 화면입니다.
records = [
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
]
line = "바람재 기록"
rains = [float(line.split("|")[4]) for line in records]
print(line, rains)
lows = []
for line in records:
    lows.append(float(line.split("|")[2]))
print(line, lows)
