# 3.2절 «practice» 1 — 하곡 11월 4일 기록으로 판정한 work/guess_hg.py 입니다.
name = "하곡"
low = 1.0
rain = 13.1
if rain > 0 and low <= 0:
    guess = "눈"
elif rain > 0:
    guess = "비"
else:
    guess = "비도 눈도 없음"
print(f"{name} 11월 4일: {guess}")
