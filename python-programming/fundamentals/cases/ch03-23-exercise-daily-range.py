# «연습하기» exercise 3 해설 — 일교차를 판정한 모범답안 work/ex3.py 입니다.
name = "바람재"
low = 1.6
high = 10.9
diff = high - low
print(f"{name} 11월 2일 일교차: {diff:.1f}도")
if diff >= 8:
    print("일교차가 큽니다.")
else:
    print("일교차가 크지 않습니다.")
