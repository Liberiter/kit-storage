# 5.1절 practice 1 — 풀이 work/sd_wet.py 입니다(지문이 요구한 화면을 먼저 싣는다).
sd_rain = [0.0, 0.0, 0.0, 8.5, 4.1, 0.0, 0.0, 0.0, 0.0, 0.0]
wet = []
for amount in sd_rain:
    if amount > 0:
        wet.append(amount)
print(f"솔등 상순 비나 눈이 온 날의 강수량: {wet}")
print(f"비나 눈이 온 날: {len(wet)}일, 합계: {sum(wet):.1f}mm")
print(f"가장 많이 온 양: {max(wet)}mm")
