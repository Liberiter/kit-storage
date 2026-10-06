# problem 2 해설 — 고친 work/day4_lines.py 입니다. 지문이 요구한 화면을 먼저 싣습니다.
def to_amount(text):
    try:
        return float(text)
    except ValueError:
        return None


def line_text(name, amount):
    return f"{name} {amount}mm"


names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
    "PT | 2025-11-04 | 결측",
]
for line in lines:
    parts = line.split("|")
    name = names.get(parts[0].strip().upper(), "목록에 없음")
    amount = to_amount(parts[2].strip())
    if amount is None:
        print(name, "결측")
    else:
        print(line_text(name, amount))
