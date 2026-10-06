# 8.1절 «흔한 실수» — 고르기 함수가 다음 단계를 직접 부르게 이은 work/chained.py 입니다.
def print_total(rows):
    total = 0.0
    for cells in rows:
        total = total + float(cells[4])
    print("강수량 합계:", round(total, 1))


def pick_rainy(rows):
    rainy = []
    for cells in rows:
        if float(cells[4]) > 0:
            rainy.append(cells)
    print_total(rainy)


sample_rows = [
    ["BJ", "2025-11-03", "0.3", "8.4", "0.0", "흐림"],
    ["BJ", "2025-11-04", "1.3", "9.3", "13.6", "비"],
]
picked = pick_rainy(sample_rows)
print(picked)
