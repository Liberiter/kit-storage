# exercise 1 — 지문의 코드이자 해설이 싣는 화면입니다 (work/ex1.py).
def add_rain(amounts, value):
    amounts.append(value)
    return amounts


bj_rain = [0.0, 13.6]
more = add_rain(bj_rain, 3.8)
backup = bj_rain[:]
backup.append(0.0)
print(more is bj_rain, backup is bj_rain)
print(bj_rain)
print(backup)
