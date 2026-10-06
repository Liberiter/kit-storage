# exercise 3 해설 (b) — in 으로 가른 work/ex3.py 입니다 (지문의 요구 화면과 같은 출력).
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
for line in lines:
    code = line.split("|")[0].strip().upper()
    if code in names:
        print(f"{code}: {names[code]}")
    else:
        print(f"{code}: 관측소 목록에 없는 코드입니다")
