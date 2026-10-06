# 11.2절 «왜 그럴까요» 셋째 블록 — 드러난 실수를 get() 으로 고친 work/count_narrow.py 입니다.
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
    except KeyError:
        name = "목록에 없음"
    counts[name] = counts.get(name, 0) + 1
print(counts)
