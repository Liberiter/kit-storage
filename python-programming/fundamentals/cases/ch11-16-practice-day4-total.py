# 11.2절 «practice» 1 풀이 work/day4_total.py 입니다. 지문이 요구한 화면을 먼저 싣습니다.
lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
    "PT | 2025-11-04 | 결측",
]
amounts = []
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    try:
        amounts.append(float(parts[2].strip()))
    except ValueError:
        print(code, "줄은 수로 바꿀 수 없어 건너뜁니다:", parts[2].strip())
print("더한 줄:", len(amounts))
print("합계:", round(sum(amounts), 1))
