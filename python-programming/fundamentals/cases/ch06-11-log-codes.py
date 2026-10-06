# 6.2절 «따라 하기» 2단계 — 현장 수첩 11월 3·4일 줄의 코드를 집합에 모으는 work/log_codes.py 입니다.
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
codes = set()
for line in lines:
    parts = line.split("|")
    codes.add(parts[0].strip().upper())
print(len(lines), len(codes))
print(sorted(codes))
