# 11.2절 «따라 하기» 3단계 — 함수 안에서 ValueError 를 잡아 None 을 돌려주는 work/day4_report.py 입니다.
def to_amount(text):
    try:
        return float(text)
    except ValueError:
        return None


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
    code = parts[0].strip().upper()
    try:
        name = names[code]
    except KeyError:
        name = "목록에 없는 관측소 " + code
    amount = to_amount(parts[2].strip())
    if amount is None:
        print(name, "결측")
    else:
        print(name, amount)
