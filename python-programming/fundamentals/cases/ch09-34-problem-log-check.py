# problem 2 해설 — 모범답안 work/log_check.py 입니다.
stations = [
    ("BJ", "바람재", 612),
    ("SD", "솔등", 447),
    ("NM", "너미", 158),
    ("HG", "하곡", 93),
    ("MR", "물레", 238),
    ("GS", "갈숲", 355),
]
lines = [
    " bj|2025-11-03|9.4",
    "sd|2025-11-03 | 8.8",
    "nm | 2025-11-03 | 결측",
    "hg|2025-11-03|7.2",
    "mr | 2025-11-03 | 0.0",
    "GS|2025-11-03|8.1",
    "pt|2025-11-03|6.6",
]
info = {}
for code, name, elevation in stations:
    info[code] = (name, elevation)
for line in lines:
    parts = line.split("|")
    code = parts[0].strip().upper()
    amount = parts[2].strip()
    found = info.get(code)
    if found is None:
        print(f"{code}: 관측소 목록에 없습니다")
    else:
        name, elevation = found
        print(f"{code} {name}({elevation}m): {amount}")
