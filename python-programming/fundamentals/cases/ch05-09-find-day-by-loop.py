# 5.2절 «문제 상황» — work/day4_loop.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
day = 0
for amount in bj_rain:
    day = day + 1
    if day == 4:
        print(f"11월 {day}일 강수량: {amount}mm")
