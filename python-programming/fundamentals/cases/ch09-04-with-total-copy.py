# 9.1절 «따라 하기» 3단계 — 함수 안에서 사본을 만들어 합계를 덧붙이는 work/with_total_copy.py 입니다.
def print_with_total(amounts):
    row = amounts[:]
    row.append(round(sum(amounts), 1))
    print("강수량과 합계:", row)


bj_rain = [0.0, 0.0, 0.0, 13.6, 3.8, 0.0, 0.0, 0.1, 0.2, 0.3]
print_with_total(bj_rain)
print(f"평균 강수량: {sum(bj_rain) / len(bj_rain):.2f}mm")
