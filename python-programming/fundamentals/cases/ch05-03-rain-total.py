# 5.1절 «따라 하기» 2단계 — work/rain_total.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
total = 0
for amount in bj_rain:
    total = total + amount
print(f"반복으로 더한 합계: {total:.1f}mm")
print(f"sum() 으로 구한 합계: {sum(bj_rain):.1f}mm")
print(f"며칠 치인가: {len(bj_rain)}일")
