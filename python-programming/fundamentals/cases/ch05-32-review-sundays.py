# 복습 exercise 2 — 모범답안 work/review2.py 입니다(지문이 요구한 화면을 먼저 싣는다).
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
for day in range(2, 31, 7):
    print(f"11월 {day}일(일요일): {bj_sky[day - 1]}")
