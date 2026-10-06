# exercise 2 해설 — 모범답안 work/ex2.py 의 화면입니다.
def snow_days(sky):
    days = [day for day, mark in enumerate(sky, start=1) if mark == "눈"]
    return len(days), days[0], days[-1]


bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
count, first, last = snow_days(bj_sky)
print(f"바람재 눈: {count}일, 처음 11월 {first}일, 마지막 11월 {last}일")
