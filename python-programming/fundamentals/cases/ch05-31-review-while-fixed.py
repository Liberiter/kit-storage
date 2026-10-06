# 복습 exercise 1 — 해설 (b) 의 고친 work/review1.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
target = 20
total = 0
day = 0
while total < target and day < len(bj_rain):
    total = total + bj_rain[day]
    day = day + 1
if total >= target:
    print(f"누적 강수가 처음으로 {target}mm 이상: 11월 {day}일 ({total:.1f}mm)")
else:
    print(f"상순 열흘 동안 {total:.1f}mm — {target}mm에 닿지 않습니다.")
