# «도전하기» problem 1 — 모범답안의 맨 위 두 줄을 솔등으로 바꾼 화면입니다 (지문의 둘째 요구 화면).
name = "솔등"
month_sky = "흐흐구비비구구흐맑흐구구눈눈맑흐맑맑구맑맑눈눈구구흐흐눈맑맑"
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
