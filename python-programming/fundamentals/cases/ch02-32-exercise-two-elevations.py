# «연습하기» exercise 4 — 지문의 화면이자 해설(모범답안 work/ex4.py)의 화면입니다.
# 612 와 355 를 입력했습니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
first = int(input("첫째 관측소 고도(m): "))
second = int(input("둘째 관측소 고도(m): "))
print(f"고도 차: {first - second}m")
print(f"평균 고도: {(first + second) / 2:.1f}m")
