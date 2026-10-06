# 8.1절 «따라 하기» 3단계 — 잇는 일을 report_station 으로 묶고 솔등을 더한 work/rain_report_two.py 입니다.
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


def report_station(records):
    rows = read_rows(records)
    rainy = pick_rainy(rows)
    print_report(rows, rainy, total_rain(rainy))


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
sd_records = [
    "SD|2025-11-01|-1.0|4.8|0.0|흐림",
    "SD|2025-11-02|-1.3|4.7|0.0|흐림",
    "SD|2025-11-03|2.3|8.9|0.0|구름많음",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "SD|2025-11-06|-0.0|8.6|0.0|구름많음",
    "SD|2025-11-07|1.2|10.0|0.0|구름많음",
    "SD|2025-11-08|-1.4|5.9|0.0|흐림",
    "SD|2025-11-09|1.3|7.3|0.0|맑음",
    "SD|2025-11-10|-2.7|5.4|0.0|흐림",
]
report_station(bj_records)
report_station(sd_records)
