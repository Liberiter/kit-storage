# problem 1 해설의 모범답안 work/weekly.py 입니다 (지문의 요구 화면과 같은 출력).
def read_rows(records):
    rows = []
    for line in records:
        rows.append(line.split("|"))
    return rows


def pick_days(rows, first, last):
    picked = []
    for cells in rows:
        day = int(cells[1][-2:])
        if day >= first and day <= last:
            picked.append(cells)
    return picked


def rainy_days(rows):
    count = 0
    for cells in rows:
        if float(cells[4]) > 0:
            count = count + 1
    return count


def total_rain(rows):
    total = 0.0
    for cells in rows:
        total = total + float(cells[4])
    return total


def lowest(rows):
    lows = []
    for cells in rows:
        lows.append(float(cells[2]))
    return min(lows)


def print_week(rows, first, last):
    week = pick_days(rows, first, last)
    rain = f"강수량 {total_rain(week):.1f}mm"
    low = f"가장 낮은 최저기온 {lowest(week)}도"
    print(f"{first}~{last}일: 비 온 날 {rainy_days(week)}일, {rain}, {low}")


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
    "BJ|2025-11-11|0.2|5.3|0.0|맑음",
    "BJ|2025-11-12|-1.3|7.1|0.0|맑음",
    "BJ|2025-11-13|-3.2|4.7|4.5|눈",
    "BJ|2025-11-14|-4.0|3.9|15.1|눈",
]
bj_rows = read_rows(bj_records)
print_week(bj_rows, 1, 7)
print_week(bj_rows, 8, 14)
