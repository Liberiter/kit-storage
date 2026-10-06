# «연습하기» exercise 4 해설 — 모범답안 work/ex4.py 입니다(지문이 요구 화면을 먼저 싣는다).
bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
first_snow = 0
last_snow = 0
day = 0
for sky in bj_sky:
    day = day + 1
    if sky == "눈":
        last_snow = day
        if first_snow == 0:
            first_snow = day
print(f"바람재 첫눈: 11월 {first_snow}일")
print(f"바람재 마지막 눈: 11월 {last_snow}일")
