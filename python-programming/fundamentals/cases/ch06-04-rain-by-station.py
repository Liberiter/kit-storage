# 6.1절 «따라 하기» 3단계 — 11월 4·5일 줄로 관측소마다 더하는 work/rain_by_station.py 입니다.
lines = [
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "GS|2025-11-04|0.9|8.7|2.0|비",
    "HG|2025-11-04|1.0|8.6|13.1|비",
    "MR|2025-11-04|0.2|6.9|9.7|비",
    "NM|2025-11-04|3.7|9.8|8.5|비",
    "SD|2025-11-04|0.9|6.0|8.5|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "GS|2025-11-05|0.2|8.0|3.1|비",
    "HG|2025-11-05|1.3|10.1|4.0|비",
    "MR|2025-11-05|0.7|9.3|2.9|비",
    "NM|2025-11-05|3.3|12.0|1.0|비",
    "SD|2025-11-05|1.7|7.8|4.1|비",
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
print(len(lines), len(totals))
for code in totals:
    print(f"{code}: {totals[code]:.1f}mm")
