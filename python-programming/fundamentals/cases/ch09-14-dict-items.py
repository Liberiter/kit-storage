# 9.2절 «따라 하기» 4단계 — items() 로 키와 값을 함께 꺼내는 work/items.py 입니다.
totals = {"BJ": 67.1, "SD": 59.4, "NM": 56.2, "HG": 58.5, "MR": 61.0, "GS": 48.6}
for pair in totals.items():
    print(pair)
for code, total in totals.items():
    if total >= 60:
        print(f"{code}: {total}mm")
