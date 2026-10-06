# «복습 exercise» 1 해설 — work/review1.py 에 447 을 입력한 화면입니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
text = input("고도(m): ")
number = int(text)
print(text * 2)
print(number * 2)
print(type(text), type(number))
print(number / 2)
