# 4.1절 «왜 그럴까요» — 누계를 0에 묶는 줄을 반복 안에 둔 work/reset_inside.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
for sky in bj_sky:
    snow_days = 0
    if sky == "눈":
        snow_days = snow_days + 1
print(f"바람재 11월 눈 온 날: {snow_days}일")
print(f"반복이 끝난 뒤 sky: {sky}")
