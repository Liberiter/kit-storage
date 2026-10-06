# 11.2절 «따라 하기» 2단계 — KeyError 를 잡아 대신 쓸 이름을 묶는 work/day3_names.py 입니다.
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
    code = line.split("|")[0].strip().upper()
    try:
        name = names[code]
    except KeyError:
        name = "목록에 없는 관측소"
    print(code, name)
