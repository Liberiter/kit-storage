# «복습 exercise» 1 해설 — 이름을 다시 묶어 영하인 관측소를 센 work/review1.py 입니다.
count = 0
low = -0.1
if low <= 0:
    count = count + 1
low = 0.0
if low <= 0:
    count = count + 1
low = 0.1
if low <= 0:
    count = count + 1
print(f"11월 17일 영하인 관측소: {count}곳")
