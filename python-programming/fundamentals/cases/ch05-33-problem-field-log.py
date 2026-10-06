# «도전하기» problem 1 — 모범답안 work/tidy_log.py 입니다(지문이 요구한 화면을 먼저 싣는다).
lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
]
most = 0
most_code = ""
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    date = parts[1].strip()
    amount_text = parts[2].strip()
    print("|".join([code, date, amount_text]))
    amount = float(amount_text)
    if amount > most:
        most = amount
        most_code = code
print(f"가장 많이 온 곳: {most_code} {most}mm")
