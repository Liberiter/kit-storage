# 4.1절 «따라 하기» 2단계 — 바람재의 눈 온 날을 세는 work/snow_days.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
snow_days = 0
for sky in bj_sky:
    if sky == "눈":
        snow_days = snow_days + 1
print(f"바람재 11월 눈 온 날: {snow_days}일")
