# exercise 2 해설 — 모범답안 work/ex2.py 입니다. 지문이 요구한 화면을 먼저 싣습니다.
lines = [
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
amounts = []
skipped = []
for line in lines:
    parts = line.split("|")
    try:
        amounts.append(float(parts[2].strip()))
    except ValueError:
        skipped.append(parts[0].strip().upper() + " " + parts[1].strip())
print("결측인 줄:", ", ".join(skipped))
print("더한 줄:", len(amounts))
print("합계:", round(sum(amounts), 1))
