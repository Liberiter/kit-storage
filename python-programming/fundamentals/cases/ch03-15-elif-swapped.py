# 3.2절 «왜 그럴까요» — 조건의 차례를 바꾼 work/guess_swapped.py 입니다.
name = "솔등"
low = 0.0
rain = 4.2
if rain > 0:
    guess = "비"
elif rain > 0 and low <= 0:
    guess = "눈"
else:
    guess = "비도 눈도 없음"
print(f"{name} 11월 14일: {guess}")
