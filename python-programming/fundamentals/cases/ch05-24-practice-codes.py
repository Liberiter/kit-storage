# 5.3절 practice 1 — 풀이 work/codes_1101.py 입니다(지문이 요구한 화면을 먼저 싣는다).
lines = [
    " bj | 2025-11-01 | 0.0",
    "Sd|2025-11-01|0.0",
    "nm | 2025-11-01|0.0",
    " HG|2025-11-01 | 0.0",
    "mr|2025-11-01|0.0",
    "gs | 2025-11-01 | 0.0",
]
codes = []
for line in lines:
    parts = line.split("|")
    codes.append(parts[0].strip().upper())
print(", ".join(codes))
