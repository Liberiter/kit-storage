# «도전하기» problem 2 — 모범답안 work/early_summary.py 입니다(지문이 요구한 화면을 먼저 싣는다).
lines = [
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
wet_days = []
total = 0
coldest = 0.0
coldest_day = 0
for line in lines:
    parts = line.split("|")
    day = int(parts[1][-2:])
    low = float(parts[2])
    rain = float(parts[4])
    if rain > 0:
        wet_days.append(f"{day}일")
        total = total + rain
    if coldest_day == 0 or low < coldest:
        coldest = low
        coldest_day = day
wet_text = ", ".join(wet_days)
print("바람재 11월 상순")
print(f"비나 눈이 온 날: {wet_text}")
print(f"강수량 합계: {total:.1f}mm")
print(f"가장 낮은 최저기온: {coldest}도 (11월 {coldest_day}일)")
