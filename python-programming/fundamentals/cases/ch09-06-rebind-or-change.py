# 9.1절 «왜 그럴까요» — 매개변수를 다시 묶는 함수와 리스트를 고치는 함수를 견주는 work/rebind.py 입니다.
def rebind(amounts):
    amounts = [0.0]
    print("함수 안:", amounts)


def change(amounts):
    amounts.append(0.0)
    print("함수 안:", amounts)


bj_rain = [13.6, 3.8]
rebind(bj_rain)
print("rebind() 뒤:", bj_rain)
change(bj_rain)
print("change() 뒤:", bj_rain)
