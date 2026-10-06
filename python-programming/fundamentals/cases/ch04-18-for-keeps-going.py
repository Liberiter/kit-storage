# 4.3절 «문제 상황» — for 와 if 로 150건을 찾으려 한 work/for_150.py 입니다.
records = 0
for day in range(1, 31):
    records = records + 6
    if records >= 150:
        print(f"11월 {day}일: {records}건")
