# «연습하기» exercise 2 — 모범답안 work/ex2.py 입니다(지문이 요구한 화면을 먼저 싣는다).
nm_high = [7.6, 10.8, 7.4, 9.8, 12.0, 7.1, 9.8, 10.7, 8.3, 7.5]
ordered = sorted(nm_high)
print(f"높은 세 값: {ordered[-3:]}")
print(f"낮은 세 값: {ordered[:3]}")
