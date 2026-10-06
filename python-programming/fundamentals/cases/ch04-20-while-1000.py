# 4.3절 «따라 하기» 2단계 — 기준만 1000건으로 바꾼 work/while_1000.py 입니다.
records = 0
day = 0
while records < 1000:
    day = day + 1
    records = records + 6
print(f"처음으로 1000건 이상이 된 날: {day}번째 날 ({records}건)")
