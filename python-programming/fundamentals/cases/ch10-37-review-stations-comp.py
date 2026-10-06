# 복습 exercise 4 해설 — 모범답안 work/review4.py 의 화면입니다.
stations = [
    ("BJ", "바람재", 612),
    ("SD", "솔등", 447),
    ("NM", "너미", 158),
    ("HG", "하곡", 93),
    ("MR", "물레", 238),
    ("GS", "갈숲", 355),
]
names = {code: name for code, name, _ in stations}
high = [station for station in stations if station[2] >= 400]
print(names)
print(high)
print(len(stations), high is stations)
