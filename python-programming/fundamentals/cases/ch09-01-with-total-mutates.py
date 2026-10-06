# 9.1절 «문제 상황» — 넘겨받은 리스트에 합계를 덧붙이는 함수 때문에 평균이 틀어지는 work/with_total.py 입니다.
def print_with_total(amounts):
    amounts.append(round(sum(amounts), 1))
    print("강수량과 합계:", amounts)


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
print_with_total(bj_rain)
print(f"평균 강수량: {sum(bj_rain) / len(bj_rain):.2f}mm")
