# 8.1절 «따라 하기» 1단계 — report.py 의 네 단계를 함수 넷으로 옮긴 work/rain_report.py 입니다.
def read_rows(records):
    rows = []
    for line in records:
        rows.append(line.split("|"))
    return rows


def pick_rainy(rows):
    rainy = []
    for cells in rows:
        if float(cells[4]) > 0:
            rainy.append(cells)
    return rainy


def total_rain(rows):
    total = 0.0
    for cells in rows:
        total = total + float(cells[4])
    return total


def print_report(rows, rainy, total):
    print("관측소:", rows[0][0])
    print("읽은 날수:", len(rows))
    print("비 온 날수:", len(rainy))
    print("강수량 합계:", round(total, 1))


bj_records = [
    "BJ|2025-11-01|-1.5|7.8|0.0|흐림",
    "BJ|2025-11-02|1.6|10.9|0.0|맑음",
    "BJ|2025-11-03|0.3|8.4|0.0|흐림",
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "BJ|2025-11-06|-1.7|7.6|0.0|구름많음",
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
]
bj_rows = read_rows(bj_records)
bj_rainy = pick_rainy(bj_rows)
print_report(bj_rows, bj_rainy, total_rain(bj_rainy))
