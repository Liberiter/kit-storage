# «도전하기» problem 1 — 모범답안 work/dry_spell.py (바람재, 지문의 첫째 요구 화면) 입니다.
name = "바람재"
month_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
run = 0
best = 0
best_end = 0
day = 0
for sky in month_sky:
    day = day + 1
    if sky == "비" or sky == "눈":
        run = 0
    else:
        run = run + 1
        if run > best:
            best = run
            best_end = day
best_start = best_end - best + 1
print(f"{name}: 비나 눈이 없던 날이 가장 길게 이어진 기간")
print(f"11월 {best_start}일부터 {best_end}일까지 {best}일")
