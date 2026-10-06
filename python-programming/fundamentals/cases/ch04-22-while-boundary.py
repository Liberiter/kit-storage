# 4.3절 «왜 그럴까요» — 조건의 < 와 <= 를 견주는 work/while_boundary.py 입니다.
records = 0
day = 0
while records < 150:
    day = day + 1
    records = records + 6
print(f"< 150 으로 적으면: 11월 {day}일 ({records}건)")
records = 0
day = 0
while records <= 150:
    day = day + 1
    records = records + 6
print(f"<= 150 으로 적으면: 11월 {day}일 ({records}건)")
