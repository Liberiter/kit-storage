# 4.1절 «흔한 실수» — print 를 반복 안에 들여쓴 work/print_inside.py 입니다.
week_sky = "흐맑흐비비구맑"
wet_days = 0
for sky in week_sky:
    if sky == "비" or sky == "눈":
        wet_days = wet_days + 1
    print(f"비나 눈이 온 날: {wet_days}일")
