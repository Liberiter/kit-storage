# exercise 2 해설의 모범답안 work/ex2.py 입니다 (지문의 요구 화면과 같은 출력).
lines = [
    "BJ|2025-11-13|-3.2|4.7|4.5|눈",
    "GS|2025-11-13|-2.7|5.3|13.6|눈",
    "HG|2025-11-13|3.5|12.9|5.6|비",
    "MR|2025-11-13|0.2|7.0|15.5|비",
    "NM|2025-11-13|-0.2|5.4|13.2|눈",
    "SD|2025-11-13|-1.4|7.4|17.4|눈",
    "BJ|2025-11-14|-4.0|3.9|15.1|눈",
    "GS|2025-11-14|0.8|7.8|5.7|비",
    "HG|2025-11-14|2.2|7.8|6.5|비",
    "MR|2025-11-14|-2.4|6.7|12.3|눈",
    "NM|2025-11-14|-1.2|6.7|2.0|눈",
    "SD|2025-11-14|0.0|6.2|4.2|눈",
]
totals = {}
for line in lines:
    parts = line.split("|")
    code = parts[0]
    rain = float(parts[4])
    if code in totals:
        totals[code] = totals[code] + rain
    else:
        totals[code] = rain
most = 0
most_code = ""
for code in totals:
    print(f"{code}: {totals[code]:.1f}mm")
    if totals[code] > most:
        most = totals[code]
        most_code = code
print(f"이틀 동안 가장 많이 온 곳: {most_code} {most:.1f}mm")
