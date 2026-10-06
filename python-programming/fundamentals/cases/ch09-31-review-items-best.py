# 복습 exercise 2 해설 — 모범답안 work/review2.py 입니다.
totals = {"BJ": 67.1, "SD": 59.4, "NM": 56.2, "HG": 58.5, "MR": 61.0, "GS": 48.6}
heavy = set()
best = ("", 0.0)
for code, total in totals.items():
    if total >= 60:
        heavy.add(code)
    if total > best[1]:
        best = (code, total)
print("60mm 이상:", ", ".join(sorted(heavy)))
print("가장 많이 온 곳:", best)
