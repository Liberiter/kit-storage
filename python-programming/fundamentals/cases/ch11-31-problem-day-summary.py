# problem 1 해설 — 모범답안 work/day_summary.py 입니다. 지문이 요구한 화면을 먼저 싣습니다.
def to_amount(text):
    try:
        return float(text)
    except ValueError:
        return None


def rainy_text(amounts):
    rainy = [amount for amount in amounts if amount > 0]
    try:
        mean = sum(rainy) / len(rainy)
    except ZeroDivisionError:
        return "비 온 곳 없음"
    return f"비 온 곳 {len(rainy)}곳 평균 {mean:.1f}mm"


names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
lines = [
    " bj | 2025-11-01 | 0.0",
    "Sd|2025-11-01|0.0",
    "nm | 2025-11-01|0.0",
    " HG|2025-11-01 | 0.0",
    "mr|2025-11-01|0.0",
    "gs | 2025-11-01 | 0.0",
    "bj|2025-11-02| 0.0",
    "sd | 2025-11-02 | 결측",
    "NM|2025-11-02|0.0",
    "hg | 2025-11-02 | 0.0",
    "MR|2025-11-02| 0.0",
    "gs|2025-11-02|결측",
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
    "PT | 2025-11-04 | 결측",
]
amounts_by_day = {}
missing_by_day = {}
unknown = 0
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    day = parts[1].strip()
    amount = to_amount(parts[2].strip())
    if day not in amounts_by_day:
        amounts_by_day[day] = []
        missing_by_day[day] = 0
    if code not in names:
        unknown = unknown + 1
    elif amount is None:
        missing_by_day[day] = missing_by_day[day] + 1
    else:
        amounts_by_day[day].append(amount)
for day, amounts in amounts_by_day.items():
    print(
        f"{day}: 기록 {len(amounts)}곳, 결측 {missing_by_day[day]}곳, "
        f"{rainy_text(amounts)}"
    )
print("목록에 없는 관측소의 줄:", unknown)
