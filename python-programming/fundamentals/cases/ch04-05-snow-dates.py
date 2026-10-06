# 4.1절 «따라 하기» 4단계 — 날짜를 함께 세는 work/snow_dates.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
day = 0
for sky in bj_sky:
    day = day + 1
    if sky == "눈":
        print(f"11월 {day}일: 눈")
