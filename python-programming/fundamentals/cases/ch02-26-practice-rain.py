# 2.3절 «practice» 1 — work/ask_rain.py 에 바람재와 13.6 을 입력한 풀이 화면입니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
name = input("관측소 이름: ")
rain = float(input("강수량(mm): "))
print(f"{name} 관측소의 강수량은 {rain:.1f}mm입니다.")
