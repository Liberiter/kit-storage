# 5.3절 «흔한 실수» — work/max_text.py 입니다.
lines = [
    "BJ|2025-11-04|1.3|9.3|13.6|비",
    "BJ|2025-11-05|1.6|10.4|3.8|비",
    "BJ|2025-11-14|-4.0|3.9|15.1|눈",
]
amounts = []
for line in lines:
    parts = line.split("|")
    amounts.append(parts[4])
print(amounts)
print(f"가장 많이 온 양: {max(amounts)}mm")
