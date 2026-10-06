# problem 1 해설 — 모범답안 work/freezing.py 의 화면입니다.
lines = [
    "BJ|2025-11-07|-1.8|3.2|0.0|맑음",
    "SD|2025-11-07|1.2|10.0|0.0|구름많음",
    "NM|2025-11-07|2.6|9.8|0.0|흐림",
    "BJ|2025-11-08|-1.4|7.2|0.1|눈",
    "SD|2025-11-08|-1.4|5.9|0.0|흐림",
    "NM|2025-11-08|2.5|10.7|0.0|흐림",
    "BJ|2025-11-09|-2.8|5.1|0.2|눈",
    "SD|2025-11-09|1.3|7.3|0.0|맑음",
    "NM|2025-11-09|1.0|8.3|0.0|구름많음",
    "BJ|2025-11-10|-1.3|7.8|0.3|눈",
    "SD|2025-11-10|-2.7|5.4|0.0|흐림",
    "NM|2025-11-10|-0.5|7.5|0.0|맑음",
]
rows = [line.split("|") for line in lines]
codes = ["BJ", "SD", "NM"]
freezing = {
    code: [cells[1][-2:] for cells in rows if cells[0] == code and float(cells[2]) < 0]
    for code in codes
}
for code, days in freezing.items():
    print(f"{code} 영하:", ", ".join(days))
