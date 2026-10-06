# «연습하기» exercise 1 — 지문의 work/ex1.py 입니다(해설이 화면을 싣는다).
total = 0
for day in range(3, 12, 4):
    total = total + day
    print(day, total)
print("합:", total)
