# problem 2 해설의 모범답안 work/snow_report.py 입니다 (지문의 요구 화면과 같은 출력).
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
lines = [
    "BJ|2025-11-22|-2.1|5.1|4.5|눈",
    "GS|2025-11-22|-4.1|1.5|8.0|눈",
    "HG|2025-11-22|-2.0|6.2|7.0|눈",
    "MR|2025-11-22|-0.9|7.0|7.1|눈",
    "NM|2025-11-22|1.4|8.3|8.6|비",
    "SD|2025-11-22|-0.4|6.5|3.1|눈",
    "BJ|2025-11-23|-5.4|2.6|16.8|눈",
    "GS|2025-11-23|-4.3|4.6|10.2|눈",
    "HG|2025-11-23|-0.2|5.4|12.7|눈",
    "MR|2025-11-23|-2.3|3.7|13.0|눈",
    "NM|2025-11-23|0.9|6.2|15.4|비",
    "SD|2025-11-23|-3.9|3.9|18.6|눈",
]
totals = {}
snow_days = {}
for line in lines:
    parts = line.split("|")
    code = parts[0]
    if code not in totals:
        totals[code] = 0
        snow_days[code] = 0
    totals[code] = totals[code] + float(parts[4])
    if parts[5] == "눈":
        snow_days[code] = snow_days[code] + 1
for code in names:
    print(f"{names[code]}: {totals[code]:.1f}mm, 눈 온 날 {snow_days[code]}일")
