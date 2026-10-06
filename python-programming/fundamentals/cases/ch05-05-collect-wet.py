# 5.1절 «따라 하기» 4단계 — work/wet_amounts.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
wet = []
for amount in bj_rain:
    if amount > 0:
        wet.append(amount)
print(wet)
print(f"비나 눈이 온 날: {len(wet)}일, 그날들의 합계: {sum(wet):.1f}mm")
