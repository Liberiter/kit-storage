# 4.1절 «따라 하기» 3단계 — 한 번의 반복으로 둘을 세는 work/wet_clear.py 입니다.
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
wet_days = 0
clear_days = 0
for sky in bj_sky:
    if sky == "비" or sky == "눈":
        wet_days = wet_days + 1
    elif sky == "맑":
        clear_days = clear_days + 1
print(f"바람재 11월 비나 눈이 온 날: {wet_days}일")
print(f"바람재 11월 맑은 날: {clear_days}일")
