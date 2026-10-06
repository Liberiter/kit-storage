# exercise 3 해설 — 모범답안 work/ex3.py 의 화면입니다.
lines = [
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "NM|2025-11-04|3.7|9.8|8.5|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
    "NM|2025-11-05|3.3|12.0|1.0|비",
]
rows = [line.split("|") for line in lines]
rain_by_day = {(cells[0], cells[1]): float(cells[4]) for cells in rows}
for key in [("NM", "2025-11-05"), ("SD", "2025-11-04"), ("HG", "2025-11-04")]:
    amount = rain_by_day.get(key)
    if amount is None:
        print(f"{key[0]} {key[1]}: 기록이 없습니다")
    else:
        print(f"{key[0]} {key[1]}: {amount}mm")
