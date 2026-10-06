# 11.2절 «흔한 실수» 고친 블록 — except 절을 둘 둔 work/day3_print.py 입니다.
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
lines = [
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
]
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    try:
        print(names[code], float(parts[2].strip()))
    except ValueError:
        print(names[code], "결측")
    except KeyError:
        print(code, "목록에 없는 관측소")
print("끝")
