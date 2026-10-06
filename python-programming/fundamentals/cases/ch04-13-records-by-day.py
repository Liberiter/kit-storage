# 4.2절 «따라 하기» 4단계 — 날짜를 블록에서 쓰는 work/records_by_day.py 입니다.
records = 0
for day in range(1, 31):
    records = records + 6
    if day == 10 or day == 20 or day == 30:
        print(f"11월 {day}일까지 쌓인 기록: {records}건")
