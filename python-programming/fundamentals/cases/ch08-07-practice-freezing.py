# 8.1절 practice 1 풀이 — 영하인 날을 고르는 보고 work/freezing_report.py 입니다 (지문의 요구 화면과 같은 출력).
def read_rows(records):
    rows = []
    for line in records:
        rows.append(line.split("|"))
    return rows


def pick_freezing(rows):
    freezing = []
    for cells in rows:
        if float(cells[2]) < 0:
            freezing.append(cells)
    return freezing


def lowest(rows):
    lows = []
    for cells in rows:
        lows.append(float(cells[2]))
    return min(lows)


def print_freezing(rows, freezing, low):
    print("관측소:", rows[0][0])
    print("읽은 날수:", len(rows))
    print("영하인 날수:", len(freezing))
    print("가장 낮은 최저기온:", low)


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
print_freezing(bj_rows, pick_freezing(bj_rows), lowest(bj_rows))
