# 11.2절 «왜 그럴까요» 첫 실험 — try 절을 넓게 잡아 실수를 덮은 work/count_wide.py 입니다 (오류 없이 틀린 화면).
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}
lines = [
    "bj | 2025-11-04 | 3.5",
    "sd|2025-11-04|3.9",
    "nm|2025-11-04 | 3.1",
    "hg | 2025-11-04 | 2.8",
    "mr|2025-11-04|0.0",
    "gs|2025-11-04| 3.3",
    "PT | 2025-11-04 | 결측",
]
counts = {}
for line in lines:
    code = line.split("|")[0].strip().upper()
    try:
        name = names[code]
        counts[name] = counts[name] + 1
    except KeyError:
        print(code, "목록에 없는 관측소라 세지 않습니다")
print(counts)
