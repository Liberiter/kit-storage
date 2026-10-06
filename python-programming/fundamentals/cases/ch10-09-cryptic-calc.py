# 10.2절 «문제 상황» — 이름으로 뜻을 알 수 없는 work/calc.py 의 실행 화면입니다.
def calc(a, b):
    c = [float(x.split("|")[4]) for x in a]
    d = [y for y in c if y > b]
    return len(d), round(sum(d), 1)


e = [
    "SD|2025-11-03|2.3|8.9|0.0|구름많음",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "SD|2025-11-06|-0.0|8.6|0.0|구름많음",
]
f, g = calc(e, 1.0)
print(f, g)
