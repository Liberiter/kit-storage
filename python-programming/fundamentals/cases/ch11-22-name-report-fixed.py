# 11.3절 «흔한 실수» 고친 블록 — 부르는 쪽에서 코드를 다듬은 work/name_report.py 입니다.
names = {
    "BJ": "바람재",
    "SD": "솔등",
    "NM": "너미",
    "HG": "하곡",
    "MR": "물레",
    "GS": "갈숲",
}


def station_name(code):
    return names[code]


lines = [
    " bj | 2025-11-01 | 0.0",
    "Sd|2025-11-01|0.0",
    "nm | 2025-11-01|0.0",
    " HG|2025-11-01 | 0.0",
    "mr|2025-11-01|0.0",
    "gs | 2025-11-01 | 0.0",
]
for line in lines:
    code = line.split("|")[0].strip().upper()
    print(station_name(code))
