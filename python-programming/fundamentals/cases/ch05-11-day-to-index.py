# 5.2절 «따라 하기» 2단계 — work/day_to_index.py 입니다.
bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
day = 4
print(f"11월 {day}일 강수량: {bj_rain[day - 1]}mm")
print(f"첫 사흘: {bj_rain[:3]}")
print(f"마지막 사흘: {bj_rain[-3:]}")
print(f"4~5일 합계: {sum(bj_rain[3:5]):.1f}mm")
