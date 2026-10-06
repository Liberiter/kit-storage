# 4.1절 practice 1 — 솔등의 비·눈 온 날과 맑은 날을 세는 work/sd_wet_clear.py 입니다.
sd_sky = "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑"
wet_days = 0
clear_days = 0
for sky in sd_sky:
    if sky == "비" or sky == "눈":
        wet_days = wet_days + 1
    elif sky == "맑":
        clear_days = clear_days + 1
print(f"솔등 11월 비나 눈이 온 날: {wet_days}일")
print(f"솔등 11월 맑은 날: {clear_days}일")
