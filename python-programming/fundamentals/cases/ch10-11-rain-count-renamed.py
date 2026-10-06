# 10.2절 «따라 하기» 1단계 — 이름만 바꾼 work/rain_count.py 의 화면입니다.
def count_heavy(lines, limit):
    amounts = [float(line.split("|")[4]) for line in lines]
    heavy = [amount for amount in amounts if amount > limit]
    return len(heavy), round(sum(heavy), 1)


sd_lines = [
    "SD|2025-11-03|2.3|8.9|0.0|구름많음",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "SD|2025-11-06|-0.0|8.6|0.0|구름많음",
]
days, total = count_heavy(sd_lines, 1.0)
print(days, total)
