# 5.3절 «따라 하기» 4단계 — work/log_1104.py 입니다.
lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
]
codes = []
total = 0
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    amount = float(parts[2].strip())
    print(f"{code}: {amount}mm")
    codes.append(code)
    total = total + amount
joined = ", ".join(codes)
print(f"관측소: {joined}")
print(f"여섯 곳 합계: {total:.1f}mm")
