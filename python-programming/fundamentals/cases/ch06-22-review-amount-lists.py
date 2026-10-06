# 복습 exercise 2 해설의 모범답안 work/review2.py 입니다 (지문의 요구 화면과 같은 출력).
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
amounts = {}
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    text = parts[2].strip()
    if text != "결측":
        if code not in amounts:
            amounts[code] = []
        amounts[code].append(float(text))
for code in amounts:
    print(f"{code}: {amounts[code]}")
