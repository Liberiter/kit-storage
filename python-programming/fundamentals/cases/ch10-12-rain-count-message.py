# 10.2절 «따라 하기» 2단계 — 긴 문장을 문자열 조각 둘로 나눈 work/rain_count.py 의 화면입니다.
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
print(
    f"솔등 11월 3~6일 가운데 하루 1.0mm 넘게 비가 온 날은 {days}일이고, "
    f"그날들의 강수량을 더하면 {total}mm입니다."
)
