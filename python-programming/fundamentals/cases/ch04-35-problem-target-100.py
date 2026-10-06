# «도전하기» problem 2 — 모범답안 work/target.py (목표 100건, 지문의 첫째 요구 화면) 입니다.
target = 100
records = 0
day = 0
while records < target and day < 30:
    day = day + 1
    records = records + 6
if records >= target:
    print(f"기록이 처음으로 {target}건 이상 쌓인 날: 11월 {day}일 ({records}건)")
else:
    print(f"11월 {day}일까지 {records}건 — {target}건에 닿지 않습니다.")
