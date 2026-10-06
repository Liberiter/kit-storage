# «도전하기» problem 1 — 지문의 화면이자 해설(모범답안 work/card.py)의 화면입니다.
# 솔등과 447 을 입력했습니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
top = 612
bottom = 93
name = input("관측소 이름: ")
elevation = int(input("고도(m): "))
rest = top - elevation
print(f"[{name}] 고도 {elevation}m")
print(f"하곡보다 {elevation - bottom}m 높고, 바람재보다 {rest}m 낮습니다.")
print(f"남은 높이는 바람재 고도의 {rest / top * 100:.1f}%입니다.")
