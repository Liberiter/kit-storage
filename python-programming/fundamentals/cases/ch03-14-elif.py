# 3.2절 «따라 하기» 4단계 — elif 로 세 갈래를 가른 work/guess_sky.py 입니다.
name = "솔등"
low = 0.0
rain = 4.2
if rain > 0 and low <= 0:
    guess = "눈"
elif rain > 0:
    guess = "비"
else:
    guess = "비도 눈도 없음"
print(f"{name} 11월 14일: {guess}")
