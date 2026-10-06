# 5.2절 «따라 하기» 4단계 — work/late_snow.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
for day in range(21, 31):
    if bj_sky[day - 1] == "눈":
        print(f"11월 {day}일: 눈")
