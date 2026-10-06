# 11.2절 «따라 하기» 1단계 work/day_total_try.py 입니다. «예측해 보기»가 같은 코드를 출력 없이 먼저 싣습니다.
lines = [
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
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
