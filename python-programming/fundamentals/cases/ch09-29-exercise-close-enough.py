# exercise 4 해설 — 모범답안 work/ex4.py 입니다.
def close_enough(a, b):
    return abs(a - b) < 0.001


checks = [
    ("바람재 8일 + 9일", 0.1 + 0.2, 0.3),
    ("바람재 4일 + 5일", 13.6 + 3.8, 17.4),
    ("솔등 4일 + 5일", 8.5 + 4.1, 12.6),
]
for label, added, expected in checks:
    same = added == expected
    near = close_enough(added, expected)
    print(f"{label}: ==로는 {same}, close_enough()로는 {near}")
