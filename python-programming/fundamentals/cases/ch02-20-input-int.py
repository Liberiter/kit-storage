# 2.3절 «따라 하기» 2단계 — work/ask_elevation.py 에 솔등과 447 을 입력한 화면입니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
name = input("관측소 이름: ")
elevation = int(input("고도(m): "))
print(f"{name} 관측소는 바람재보다 {612 - elevation}m 낮습니다.")
