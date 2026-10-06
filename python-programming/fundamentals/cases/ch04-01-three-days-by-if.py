# 4.1절 «문제 상황» — 3장의 방식으로 사흘을 판정한 work/wet_3days.py 입니다.
wet_days = 0
sky = "비"
if sky == "비" or sky == "눈":
    wet_days = wet_days + 1
sky = "비"
if sky == "비" or sky == "눈":
    wet_days = wet_days + 1
sky = "구름많음"
if sky == "비" or sky == "눈":
    wet_days = wet_days + 1
print(f"바람재 11월 4~6일 비나 눈이 온 날: {wet_days}일")
