# 7.2절 «따라 하기» 3단계 — 기본값을 둔 매개변수의 work/count_days.py 입니다.
def count_days(name, sky, target="눈"):
    count = 0
    for letter in sky:
        if letter == target:
            count = count + 1
    print(f"{name}: {target} {count}일")


bj_sky = "흐맑흐비비구맑눈눈눈맑맑눈눈흐맑구맑맑구구눈눈흐구구구눈구구"
count_days("바람재", bj_sky)
count_days("바람재", bj_sky, "맑")
count_days("바람재", bj_sky, target="비")
