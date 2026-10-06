# «도전하기» problem 2 — 지문의 화면이자 해설(모범답안 work/rain_total.py)의 화면입니다.
# 바람재의 11월 4~6일 강수량(13.6, 3.8, 0.0)을 입력했습니다.
# 입력 줄은 같은 이름의 .stdin 에 있고 러너가 표준 입력으로 흘려 넣습니다. 파이프로
# 넣으므로 본문 화면에 되비친 입력 글자와 그 줄바꿈은 이 케이스의 출력에 없습니다.
total = 0.0
total = total + float(input("강수량(mm): "))
print(f"누계 {total:.1f}mm")
total = total + float(input("강수량(mm): "))
print(f"누계 {total:.1f}mm")
total = total + float(input("강수량(mm): "))
print(f"누계 {total:.1f}mm")
