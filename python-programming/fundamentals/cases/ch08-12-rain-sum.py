# 8.2절 «따라 하기» 4단계 — 반복문과 재귀로 합계를 내는 work/rain_sum.py 입니다.
def rain_sum(amounts):
    if len(amounts) == 0:
        return 0.0
    else:
        return amounts[0] + rain_sum(amounts[1:])


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
total = 0.0
for amount in bj_rain:
    total = total + amount
print(f"반복문: {total:.1f}mm")
print(f"재귀: {rain_sum(bj_rain):.1f}mm")
print(f"세 날만: {rain_sum([13.6, 3.8, 0.1]):.1f}mm")
